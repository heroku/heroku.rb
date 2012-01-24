module Heroku
  class API < Excon::Connection

    # DELETE /apps/:app/domains/:domain
    def delete_domain(app, domain)
      request(
        :expects  => 200,
        :method   => :delete,
        :path     => "/apps/#{app}/domains/#{CGI.escape(domain)}"
      )
    end

    # GET /apps/:app/domains
    def get_domains(app)
      request(
        :expects  => 200,
        :method   => :get,
        :path     => "/apps/#{app}/domains"
      )
    end

    # POST /apps/:app/domains
    def post_domain(app, domain)
      request(
        :expects  => 201,
        :method   => :post,
        :path     => "/apps/#{app}/domains",
        :query    => {'domain_name[domain]' => domain}
      )
    end

  end
end
