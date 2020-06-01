# -*- encoding : utf-8 -*-
require 'spec_helper'

describe PackagePlan do
  subject { FactoryGirl.create(:active_package_plan) }

  [:members_limit].each do |attr|
    it { should validate_presence_of attr }
  end
end
