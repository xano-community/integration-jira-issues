function "jira_create_issue" {
  description = "Create a new Jira issue/ticket"
  input {
    text project_key { description = "Jira project key (e.g. PROJ)" }
    text summary { description = "Issue summary/title" }
    text issue_type?="Task" { description = "Issue type: Task, Bug, Story, Epic, etc." }
    text description? { description = "Issue description (Atlassian Document Format or plain text)" }
    text priority? { description = "Priority name: Highest, High, Medium, Low, Lowest" }
    text assignee? { description = "Assignee account ID" }
    json labels? { description = "Array of label strings" }
  }
  stack {
    var $auth_string { value = ($env.JIRA_EMAIL ~ ":" ~ $env.JIRA_API_TOKEN)|base64_encode }

    var $fields {
      value = {
        project: { key: $input.project_key },
        summary: $input.summary,
        issuetype: { name: $input.issue_type }
      }
    }
    var.update $fields { value = $fields|set_ifnotnull:"description":$input.description }
    var.update $fields { value = $fields|set_ifnotnull:"labels":$input.labels }

    conditional {
      if ($input.priority != null) {
        var.update $fields { value = $fields|set:"priority":{ name: $input.priority } }
      }
    }
    conditional {
      if ($input.assignee != null) {
        var.update $fields { value = $fields|set:"assignee":{ accountId: $input.assignee } }
      }
    }

    api.request {
      url = $env.JIRA_BASE_URL ~ "/rest/api/3/issue"
      method = "POST"
      headers = ["Authorization: Basic " ~ $auth_string, "Content-Type: application/json"]
      params = { fields: $fields }
      mock = {
        "creates issue successfully": { response: { status: 201, result: { id: "10001", key: "PROJ-42", self: "https://yoursite.atlassian.net/rest/api/3/issue/10001" } } }
      }
    } as $api_result

    precondition ($api_result.response.status == 201) {
      error_type = "standard"
      error = "Jira API error: " ~ $api_result.response.result
    }

    var $result { value = $api_result.response.result }
  }
  response = $result

  test "creates issue successfully" {
    input = { project_key: "PROJ", summary: "Fix login bug", issue_type: "Bug" }
    expect.to_equal ($response.key) { value = "PROJ-42" }
    expect.to_not_be_null ($response.id)
  }
}