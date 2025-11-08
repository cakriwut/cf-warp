# GitHub Copilot Agents

This document describes the AI agents available in this repository to help with development tasks.

## Available Agents

### General Purpose Agent

The default GitHub Copilot agent can help with:
- Code review and suggestions
- Bug fixing and debugging
- Documentation updates
- Test creation
- Refactoring recommendations

### Usage

To use GitHub Copilot agents in this repository:

1. **In GitHub Copilot Chat (e.g., in VS Code, Visual Studio, or GitHub.com)**: Use the `/` commands to interact with agents
   - `/plan` - Create a plan for implementing changes
   - `/implement` - Execute the planned changes
   - `/review` - Review code changes
   - `/test` - Generate or run tests
   - `/docs` - Update documentation

2. **In Pull Requests**: Tag `@copilot` in PR comments to get assistance with:
   - Code review
   - Suggesting improvements
   - Explaining changes
   - Identifying potential issues

3. **In Issues**: Tag `@copilot` to:
   - Break down complex tasks
   - Get implementation suggestions
   - Understand requirements better

## Best Practices

- **Be specific**: Provide clear context and requirements when requesting help
- **Iterative approach**: Break down complex tasks into smaller steps
- **Review carefully**: Always review agent-generated code and suggestions
- **Test thoroughly**: Verify that changes work as expected in your environment

## Repository-Specific Guidelines

For this Cloudflare WARP Docker container project:

- Ensure all Docker-related changes are tested in a container environment
- Update documentation when modifying configuration options
- Verify WARP connectivity after infrastructure changes
- Follow the existing code style and patterns
- Keep the container image size minimal

## Contributing with Agents

When using agents to contribute to this project:

1. Agents can help create new features or fix bugs
2. Always test Docker builds locally before submitting PRs
3. Update relevant documentation (README.md, docs/usage-guide.md, docs/docker-hub-setup.md)
4. Ensure changes don't break existing functionality
5. Follow the contributing guidelines in the repository

## Feedback

If you have suggestions for improving agent interactions or this documentation, please open an issue or submit a pull request.
