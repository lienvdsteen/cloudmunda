# frozen_string_literal: true

require 'zeebe/client'

module Cloudmunda
  module Zeebe
    class Client
      include ::Cloudmunda::Loggable

      attr_reader :client

      def initialize(url: ::Cloudmunda.zeebe_url)
        @client = ::Zeebe::Client::GatewayProtocol::Gateway::Stub.new(url, authentication_headers)
      end

      def activate_jobs(params = {})
        run(:activate_jobs,
            ::Zeebe::Client::GatewayProtocol::ActivateJobsRequest.new(params))
      end

      def cancel_process_instance(params = {})
        run(:cancel_process_instance,
            ::Zeebe::Client::GatewayProtocol::CancelProcessInstanceRequest.new(params))
      end

      # @deprecated Use {#cancel_process_instance} instead. This method is deprecated
      #   as of Camunda 8.0 and will be removed in Camunda 8.10.
      def cancel_workflow_instance(params = {})
        warn_deprecation('cancel_workflow_instance', 'cancel_process_instance')
        run(:cancel_workflow_instance,
            ::Zeebe::Client::GatewayProtocol::CancelWorkflowInstanceRequest.new(params))
      end

      def complete_job(params = {})
        run(:complete_job,
            ::Zeebe::Client::GatewayProtocol::CompleteJobRequest.new(params))
      end

      def create_process_instance(params = {})
        run(:create_process_instance,
            ::Zeebe::Client::GatewayProtocol::CreateProcessInstanceRequest.new(params))
      end

      def deploy_resource(params = {})
        run(:deploy_resource,
            ::Zeebe::Client::GatewayProtocol::DeployResourceRequest.new(params))
      end

      # @deprecated Use {#deploy_resource} instead. The DeployProcess gRPC endpoint
      #   was deprecated in Camunda 8.0 and will be removed in Camunda 8.10.
      #   Note: Parameter structure has changed - use `resources` instead of `processes`,
      #   and `content` instead of `definition`.
      def deploy_process(params = {})
        warn_deprecation('deploy_process', 'deploy_resource')
        run(:deploy_process,
            ::Zeebe::Client::GatewayProtocol::DeployProcessRequest.new(params))
      end

      def fail_job(params = {})
        run(:fail_job,
            ::Zeebe::Client::GatewayProtocol::FailJobRequest.new(params))
      end

      def throw_error(params = {})
        run(:throw_error,
            ::Zeebe::Client::GatewayProtocol::ThrowErrorRequest.new(params))
      end

      def publish_message(params = {})
        run(:publish_message,
            ::Zeebe::Client::GatewayProtocol::PublishMessageRequest.new(params))
      end

      def resolve_incident(params = {})
        run(:resolve_incident,
            ::Zeebe::Client::GatewayProtocol::ResolveIncidentRequest.new(params))
      end

      def set_variables(params = {})
        run(:set_variables,
            ::Zeebe::Client::GatewayProtocol::SetVariablesRequest.new(params))
      end

      def topology(params = {})
        run(:topology,
            ::Zeebe::Client::GatewayProtocol::TopologyRequest.new(params))
      end

      def update_job_retries(params = {})
        run(:update_job_retries,
            ::Zeebe::Client::GatewayProtocol::UpdateJobRetriesRequest.new(params))
      end

      private

      def run(method, params = {})
        client.public_send(method, params)
      rescue ::GRPC::Unavailable => e
        logger.error e.message
        raise e
      end

      def authentication_headers
        token = Cloudmunda::API::AccessToken.create
        channel_creds = GRPC::Core::ChannelCredentials.new
        auth_proc = proc { { 'authorization' => "Bearer #{token.access_token}" } }
        call_creds = GRPC::Core::CallCredentials.new(auth_proc)
        channel_creds.compose(call_creds)
      end
    end
  end
end
