# @author anthony
# @date  2023/3/22
module Proxy
  class API < Grape::API
    version 'v1', using: :path
    format :json

    desc 'Routes a request to an external API'
    params do
      requires :url, type: String, desc: 'URL of the target API endpoint'
      optional :method, type: String, default: 'GET', values: %w[GET POST PUT DELETE], desc: 'HTTP method'
      optional :headers, type: Hash, default: {}, desc: 'HTTP headers'
      optional :payload, type: Hash, default: {}, desc: 'Request payload'
      optional :headers_field, type: Array, default: [], desc: 'Need return headers'
      optional :verify_ssl, type: Boolean, default: false, desc: 'Need return headers'
    end

    post :request do
      begin
        response = RestClient::Request.execute(
          method: params[:method],
          url: params[:url],
          headers: params[:headers],
          payload: params[:payload],
          verify_ssl: params[:verify_ssl]
        ){ |response|
          headers = response.headers.with_indifferent_access
          result = JSON.parse(response)
          if params[:headers_field].present?
            return_headers = params[:headers_field].map { |key| [key, headers[key]] }
            result = result.merge(return_headers.to_h)
          end
          result
        }
        status 200
        response
      rescue RestClient::ExceptionWithResponse, StandardError => e
        error!(e,400)
      end
    end

  end
end
