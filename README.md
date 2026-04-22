# Jira Integration for Xano

Create issues and manage workflow transitions in Jira directly from your Xano workflows.

## Functions

| Function | Description |
| --- | --- |
| `jira_create_issue` | Creates a new issue in a Jira project. |
| `jira_transition_issue` | Transitions a Jira issue to a new workflow status. |

## Install

### Option A — Ask Claude Code

With the [Xano MCP](https://github.com/xano-labs/mcp-server) enabled in Claude Code, paste this into Claude:

> Install the integration at https://github.com/xano-community/integration-jira-issues into my Xano workspace.

Claude will clone the repo and push the functions to your workspace.

### Option B — Use the Xano CLI

1. Install and authenticate the [Xano CLI](https://docs.xano.com/cli):
   ```sh
   npm install -g @xano/cli
   xano auth
   ```

2. Clone and push this integration:
   ```sh
   git clone https://github.com/xano-community/integration-jira-issues.git
   cd integration-jira-issues
   xano workspace:push . -w <your-workspace-id>
   ```

   Replace `<your-workspace-id>` with the ID from `xano workspace:list`.

## Configure Credentials

1. Log in to your Atlassian account at id.atlassian.com.
2. Navigate to Security > API tokens and create a new API token.
3. Note your Jira instance base URL (e.g., https://yoursite.atlassian.net).
4. In your Xano workspace, set the environment variable JIRA_EMAIL to your Atlassian account email.
5. Set the environment variable JIRA_API_TOKEN to your API token.
6. Set the environment variable JIRA_BASE_URL to your Jira instance URL.

Environment variables used by this integration:

- `JIRA_API_TOKEN`
- `JIRA_BASE_URL`
- `JIRA_EMAIL`

See `.env.example` for a template.

## Usage

Call any function from another function, task, or API endpoint using `function.run`:

```xs
function.run "jira_create_issue" {
  input = {
    // See function signature for required parameters
  }
} as $result
```

## Function Reference

### `jira_create_issue`

Creates an issue in a specified Jira project with a summary, description, and issue type (e.g., Task, Bug, Story). Supports setting priority and other standard fields. Use this to automatically generate tickets from bug reports, customer feedback, or internal workflow triggers in your application.

### `jira_transition_issue`

Moves an existing Jira issue from its current status to a new one by applying a workflow transition. Requires the issue key and the target transition ID. Ideal for automating status updates such as moving tickets to 'In Progress' or 'Done' based on events in your Xano backend.

## License

MIT — see [LICENSE](./LICENSE).
