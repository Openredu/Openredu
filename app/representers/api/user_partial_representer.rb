# -*- encoding : utf-8 -*-
module Api
  module UserPartialRepresenter
    include Roar::Representer::JSON
    include Roar::Representer::Feature::Hypermedia

    include Api::ThumbnailCollection

    property :id
    property :login
    property :first_name
    property :last_name

    link :self do
      api_user_url(self)
    end

    link :enrollments do
      api_user_enrollments_url(self)
    end

    link :statuses do
      api_user_statuses_url(self)
    end

    link :timeline do
      timeline_api_user_statuses_url(self)
    end

    link :contacts do
      api_user_contacts_url(self)
    end

    link :connections do
      api_user_connections_url(self)
    end
  end
end
