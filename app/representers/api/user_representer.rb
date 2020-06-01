# -*- encoding : utf-8 -*-
module Api
  module UserRepresenter
    include Roar::Representer::JSON
    include Roar::Representer::Feature::Hypermedia

    include Api::ThumbnailCollection

    property :id
    property :login
    property :email
    property :first_name
    property :last_name
    property :description
    property :favorite_quotation
    property :birthday
    property :friends_count
    property :mobile
    property :localization
    property :birth_localization
    property :created_at
    property :updated_at
    collection :tags, :from => :interested_areas, :extend => TagRepresenter
    collection :social_networks, :extend => SocialNetworkRepresenter,
      :class => SocialNetwork
    property :languages
    
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
