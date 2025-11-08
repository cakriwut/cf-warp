#!/bin/bash

# Allow the script to continue even if some commands fail
set +e

echo "Starting WARP container..."

# Check and remove existing D-Bus pid file if it exists
if [ -f "/run/dbus/pid" ]; then
  echo "Removing existing D-Bus pid file"
  rm -f /run/dbus/pid
fi

# Create TUN device if it doesn't exist
if [ ! -c /dev/net/tun ]; then
  echo "Creating TUN device"
  mknod /dev/net/tun c 10 200
  chmod 600 /dev/net/tun
fi

# Start D-Bus daemon
echo "Starting D-Bus daemon..."
mkdir -p /var/run/dbus
dbus-daemon --system --fork
sleep 3

# Start WARP service
echo "Starting WARP service..."
warp-svc &
WARP_SVC_PID=$!
sleep 5

# Check if registration exists by looking for reg.json files
REGISTRATION_EXISTS=false
if [ -f "/var/lib/cloudflare-warp/reg.json" ] || [ -f "/var/lib/cloudflare-warp/reg_mdm.orgs.json" ] || [ -f "/var/lib/cloudflare-warp/mdm.xml" ]; then
  echo "Existing registration files found"
  REGISTRATION_EXISTS=true
else
  echo "No existing registration files found"
fi

echo "yes" > /root/.local/share/warp/accepted-tos.txt
echo "yes" > /root/.local/share/warp/accepted-teams-tos.txt
chmod 644 /root/.local/share/warp/accepted-tos.txt /root/.local/share/warp/accepted-teams-tos.txt

# Handle registration based on FORCE environment variable
if [ "$REGISTRATION_EXISTS" = true ]; then
  warp-cli connect
  sleep 2
  #rm -rf /var/lib/cloudflare-warp/*
else
  echo "Registering with connector token..."
  warp-cli connector new $WARP_TOKEN
  sleep 2
  echo "Connecting to WARP..."
  warp-cli connect
  sleep 2
fi

echo "WARP setup complete!"
warp-cli status

# Select the appropriate VNET based on environment variable
select_vnet

echo "Container running. Press Ctrl+C to stop."

# Function to check connection status and reconnect if needed
check_connection() {
  local status_output
  status_output=$(warp-cli status 2>&1)
  
  echo "[$(date)] WARP status:"
  echo "$status_output"
  
  if echo "$status_output" | grep -q "Status update: Connected"; then
    echo "✅ WARP is connected"
  else
    echo "❌ WARP is not connected, attempting to reconnect..."
    warp-cli connect
    sleep 5
    local reconnect_status
    reconnect_status=$(warp-cli status 2>&1)
    echo "$reconnect_status"
    
    if echo "$reconnect_status" | grep -q "Status update: Connected"; then
      echo "✅ WARP reconnection successful"
    else
      echo "❌ WARP reconnection failed"
    fi
  fi
}

# Function to select the appropriate VNET based on environment variable
select_vnet() {
  echo "[$(date)] Checking VNET selection..."
  
  local vnet_output
  vnet_output=$(warp-cli vnet 2>&1)
  local exit_code=$?
  
  if [ $exit_code -ne 0 ]; then
    echo "❌ Failed to retrieve VNET information (exit code: $exit_code)"
    echo "Error output: $vnet_output"
    return 1
  fi
  
  # Get currently selected VNET ID and name
  local current_id
  local current_name
  
  current_id=$(echo "$vnet_output" | grep "Currently selected:" | sed 's/^Currently selected: //')
  
  if [ -n "$current_id" ]; then
    current_name=$(echo "$vnet_output" | grep -A1 "ID: $current_id" | grep "Name:" | sed 's/^.*Name: //')
  fi
  
  # Determine target VNET
  local target_name
  local target_id
  
  if [ -n "$VNET" ]; then
    # Use the VNET environment variable if set
    target_name="$VNET"
    echo "Environment variable VNET is set to: $target_name"
  else
    # Find the default VNET if VNET env var is not set
    local default_line
    default_line=$(echo "$vnet_output" | grep -B2 "Default: true" | grep "ID:" | head -n1)
    
    if [ -n "$default_line" ]; then
      target_id=$(echo "$default_line" | sed 's/^.*ID: //')
      target_name=$(echo "$vnet_output" | grep -A1 "ID: $target_id" | grep "Name:" | sed 's/^.*Name: //')
      echo "No VNET environment variable set, using default VNET: $target_name"
    else
      echo "❌ No default VNET found and no VNET environment variable set"
      return 1
    fi
  fi
  
  # Check if we need to switch VNET
  if [ "$current_name" = "$target_name" ]; then
    echo "✅ Already using the correct VNET: $current_name"
    return 0
  fi
  
  # Find the VNET ID for the target name
  if [ -z "$target_id" ]; then
    local name_line
    name_line=$(echo "$vnet_output" | grep -B1 "Name: $target_name" | grep "ID:" | head -n1)
    
    if [ -n "$name_line" ]; then
      target_id=$(echo "$name_line" | sed 's/^.*ID: //')
    else
      echo "❌ Could not find VNET with name: $target_name"
      return 1
    fi
  fi
  
  # Switch to the target VNET
  if [ -n "$target_id" ]; then
    echo "Switching to VNET: $target_name (ID: $target_id)"
    local switch_output
    switch_output=$(warp-cli vnet "$target_id" 2>&1)
    local switch_exit_code=$?
    
    if [ $switch_exit_code -eq 0 ]; then
      echo "✅ Successfully switched to VNET: $target_name"
    else
      echo "❌ Failed to switch VNET (exit code: $switch_exit_code)"
      echo "Error output: $switch_output"
      return 1
    fi
  fi
  
  return 0
}

# Function to display current vnet information
display_vnet_info() {
  echo "[$(date)] VNET information:"
  
  local vnet_output
  vnet_output=$(warp-cli vnet 2>&1)
  local exit_code=$?
  
  if [ $exit_code -eq 0 ]; then
    
    # Extract and display the currently selected vnet id and name
    local selected_id
    local selected_name
    
    # Extract the selected ID from "Currently selected: <ID>"
    selected_id=$(echo "$vnet_output" | grep "Currently selected:" | sed 's/^Currently selected: //')
    
    if [ -n "$selected_id" ]; then
      # Find the name for the selected ID
      selected_name=$(echo "$vnet_output" | grep -A1 "ID: $selected_id" | grep "Name:" | sed 's/^.*Name: //')
      
      echo "Currently selected VNET:"
      echo "  ID: $selected_id"
      
      if [ -n "$selected_name" ]; then
        echo "  Name: $selected_name"
      else
        echo "  Name: Unknown"
      fi
    else
      echo "No VNET currently selected"
    fi
  else
    echo "❌ Failed to retrieve VNET information (exit code: $exit_code)"
    echo "Error output: $vnet_output"
  fi
}

# Function to handle errors and cleanup on exit
cleanup() {
  echo "[$(date)] Cleaning up before exit..."
  warp-cli disconnect >/dev/null 2>&1
  kill $WARP_SVC_PID >/dev/null 2>&1
  echo "Cleanup complete"
  exit 0
}

# Set up trap for cleanup on script termination
trap cleanup SIGINT SIGTERM

# Keep container running and show status every minute
echo "Starting monitoring loop - checking status every minute"
echo "-----------------------------------"

while true; do
  # Check connection status and reconnect if needed
  check_connection
  
  # Select the appropriate VNET
  select_vnet
  
  # Display vnet information
  display_vnet_info
  
  echo "-----------------------------------"
  sleep 60
done