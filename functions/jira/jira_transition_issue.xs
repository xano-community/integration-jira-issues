function "jira_transition_issue" {
  description = "Transition a Jira issue to a new status"
  input {
    text issue_key { description = "Issue key (e.g. PROJ-123)" }
    text transition_id { description = "Transition ID to apply (get from /transitions endpoint)" }
    text comment? { description = "Comment to add with the transition" }
  }
  stack {
    var $auth_string { value = ($env.JIRA_EMAIL ~ ":" ~ $env.JIRA_API_TOKEN)|base64_encode }

    var $params {
      value = {
        transition: { id: $input.transition_id }
      }
    }

    conditional {
      if ($input.comment != null) {
        var.update $params {
          value = $params|set:"update":{
            comment: [{
              add: {
                body: $input.comment
              }
            }]
          }
        }
      }
    }

    api.request {
      url = $env.JIRA_BASE_URL ~ "/rest/api/3/issue/" ~ $input.issue_key ~ "/transitions"
      method = "POST"
      headers = ["Authorization: Basic " ~ $auth_string, "Content-Type: application/json"]
      params = $params
      mock = {
        "transitions issue successfully": { response: { status: 204, result: "" } }
      }
    } as $api_result

    precondition ($api_result.response.status == 204) {
      error_type = "standard"
      error = "Jira API error: " ~ $api_result.response.result
    }

    var $result {
      value = {
        issue_key: $input.issue_key,
        transition_id: $input.transition_id,
        status: "transitioned"
      }
    }
  }
  response = $result

  test "transitions issue successfully" {
    input = { issue_key: "PROJ-42", transition_id: "31" }
    expect.to_equal ($response.issue_key) { value = "PROJ-42" }
    expect.to_equal ($response.status) { value = "transitioned" }
  }
}