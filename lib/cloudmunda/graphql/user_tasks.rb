# frozen_string_literal: true

module Cloudmunda
  module Graphql
    class UserTasks
      def self.all
        query = "{
          tasks(query: { state: CREATED })
          {
            id
            taskDefinitionId
            name
            taskState
            assignee
            taskState
            isFirst
            formKey
            processDefinitionId
            completionTime
            processName
            variables {
              name
              value
            }
          }
        }"
        Cloudmunda::Graphql::Client.post(query: query)['data']['tasks']
      end

      def self.run_mutation(mutation)
        Cloudmunda::Graphql::Client.post(query: mutation)
      end
    end
  end
end
