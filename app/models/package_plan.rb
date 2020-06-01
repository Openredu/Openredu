# -*- encoding : utf-8 -*-
class PackagePlan < Plan

  PLANS = {
    :free => {
      :name => "Professor Grátis",
      :video_storage_limit => 10.megabytes,
      :file_storage_limit => 5.megabytes,
      :members_limit => 30
    },
    :professor_lite => {
      :name => "Professor Lite",
      :video_storage_limit => 30.megabytes,
      :file_storage_limit => 25.megabytes,
      :members_limit => 70
    },
    :professor_standard => {
      :name => "Professor Standard",
      :video_storage_limit => 90.megabytes,
      :file_storage_limit => 25.megabytes,
      :members_limit => 100
    },
    :professor_plus => {
      :name => "Professor Plus",
      :video_storage_limit => 150.megabytes,
      :file_storage_limit => 25.megabytes,
      :members_limit => 500
    },
    :instituicao_medio_tiny => {
      :name => "Instituição de Ensino Médio Tiny",
      :video_storage_limit => 512.megabytes,
      :file_storage_limit => 512.megabytes,
      :members_limit => 200
    },
    :instituicao_medio_lite => {
      :name => "Instituição de Ensino Médio Lite",
      :video_storage_limit => 512.megabytes,
      :file_storage_limit => 512.megabytes,
      :members_limit => 300
    },
    :instituicao_medio_standard => {
      :name => "Instituição de Ensino Médio Standard",
      :video_storage_limit => 512.megabytes,
      :file_storage_limit => 512.megabytes,
      :members_limit => 400
    },
    :instituicao_medio_plus => {
      :name => "Instituição de Ensino Médio Plus",
      :video_storage_limit => 512.megabytes,
      :file_storage_limit => 512.megabytes,
      :members_limit => 500
    }
  }

  validates_presence_of :members_limit
end
