# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Plan do
  before do
    UserNotifier.delivery_method = :test
    UserNotifier.perform_deliveries = true
  end

  subject { FactoryGirl.create(:plan) }

  it { should belong_to :billable }
  it { should belong_to :user }
  it { should_not allow_mass_assignment_of :state }
  it { should_not allow_mass_assignment_of :billable_audit }
  it { should validate_presence_of :user }

  context "states" do
    [:block!, :migrate!, :activate!, :state].each do |attr|
      it "responds to" do
        should respond_to attr
      end
    end

    it "defaults to active" do
      subject.state.should == "active"
    end

    it "shoould reactivate withdout error" do
      expect {
        subject.activate!
      }.to_not change { subject.state }
    end

    it "blocks" do
      expect {
        subject.block!
      }.to change { subject.state }.to "blocked"
    end

    it "sends an email when blocked" do
      expect {
        subject.block!
      }.to change {UserNotifier.deliveries.size }.by(1)
      UserNotifier.deliveries.last.body.should =~ /foi bloqueado/
    end

    it "migrates" do
      expect {
        subject.migrate!
      }.to change { subject.state }.to "migrated"
    end

    it "activates" do
      subject.block!

      expect {
        subject.activate!
      }.to change(subject, :state).from("blocked").to("active")
    end
  end

  context "when creating a preset" do
    it "should respond to from_preset" do
      Plan.should respond_to(:from_preset)
    end

    it "creates a plan from preset" do
      plan = Plan.from_preset(:professor_standard)
      plan.user = FactoryGirl.create(:user)
      plan.should be_valid
    end
  end

  context "when pre setting a package plan" do
    before do
      @plan = Plan.from_preset(:professor_lite, "PackagePlan")
    end

    it "should initialize a valid plan" do
      @plan.user = FactoryGirl.create(:user)
      @plan.should be_valid
    end

    it "should have the correct informations" do
      @plan.name.should == PackagePlan::PLANS[:professor_lite][:name]
    end

    it "should be a PartnerPlan" do
      @plan.is_a?(PackagePlan).should be_true
    end

    context "when trying to preset a inexistent type of plan" do
      before do
        @another_plan = Plan.from_preset(:professor_lite, "CoolPlan")
      end

      it "should return a plan with type PackagePlan" do
        @another_plan.class.should == PackagePlan
      end

      it "should return a plan with correct name in this case" do
        @another_plan.name.should == PackagePlan::PLANS[:professor_lite][:name]
      end
    end

    context "when trying to preset a inexistent plan" do
      before do
        @another_plan = Plan.from_preset(:inexistent)
      end

      it "should return a plan with correct name" do
        @another_plan.name.should == PackagePlan::PLANS[:free][:name]
      end
    end
  end

  context "when migrating to another plan" do
    let(:subject) { FactoryGirl.create(:plan) }

    context "when upgrading" do
      before do
        @billable = subject.billable

        @new_plan = FactoryGirl.build(:active_package_plan)
      end

      it "should change to migrated" do
        expect {
          subject.migrate_to @new_plan
        }.to change{ subject.state }.to("migrated")
      end

      it "should have new plan as current" do
        subject.migrate_to @new_plan
        @billable.plan.should == @new_plan
      end

      it "should associate the new plan with the billable" do
        billable = subject.billable
        subject.migrate_to @new_plan
        @new_plan.billable.should == billable
      end

      it "should associate the new plan with the user" do
        user = subject.user
        subject.migrate_to @new_plan
        @new_plan.user.should == user
      end
    end

    context "when downgrading" do
      before do
        @billable = subject.billable

        @new_plan = FactoryGirl.build(:active_package_plan)
      end
    end
  end

  context "when billable is destroyed" do
    before do
      subject.billable.audit_billable_and_destroy
      subject.reload
    end

    it "sends email when blocked" do
      expect {
        subject.block!
      }.to change(UserNotifier.deliveries, :count).by(1)
    end
  end


  context "when a plan blocks all billable access" do
    context "when billable is a course" do
      subject { FactoryGirl.create(:plan, :billable => FactoryGirl.create(:complete_course)) }

      before do
        @course = subject.billable
        (1..3).each { @course.join! FactoryGirl.create(:user) }

        subject.block_all_access!
      end

      it "should mark course as blocked" do
        @course.reload.should be_blocked
      end

      it "should mark all spaces as blocked" do
        @course.spaces.each do |space|
          space.reload.should be_blocked
        end
      end

      it "should mark all subjects as blocked" do
        @course.spaces.collect(&:subjects).flatten.each do |subj|
          subj.should be_blocked
        end
      end

      it "should mark all lectures as blocked" do
        subjects = @course.spaces.collect(&:subjects).flatten
        subjects.collect(&:lectures).flatten.each do |subj|
          subj.should be_blocked
        end
      end
    end

    context "when billable is a environment" do
      subject { FactoryGirl.create(:plan, :billable => FactoryGirl.create(:complete_environment)) }

      before do
        @environment = subject.billable
        @environment.courses << FactoryGirl.create(:complete_course,
                                        :environment => @environment)
        @course1, @course2 = @environment.courses
        (1..3).each { @course1.join! FactoryGirl.create(:user) }
        (1..2).each { @course2.join! FactoryGirl.create(:user) }

        subject.block_all_access!
      end

      it "should mark environment as blocked" do
        @environment.reload.should be_blocked
      end

      it "should mark all courses as blocked" do
        @course1.reload.should be_blocked
        @course2.reload.should be_blocked
      end

      it "should mark all spaces as blocked" do
        spaces = (@course1.spaces + @course2.spaces).flatten
        spaces.each do |space|
          space.reload.should be_blocked
        end
      end

      it "should mark all subjects as blocked" do
        subjects = @course1.spaces.collect(&:subjects).flatten +
          @course1.spaces.collect(&:subjects).flatten

        subjects.flatten.each do |subj|
          subj.should be_blocked
        end
      end

      it "should mark all lectures as blocked" do
        subjects = @course1.spaces.collect(&:subjects).flatten +
          @course1.spaces.collect(&:subjects).flatten

        subjects.collect(&:lectures).flatten.each do |lecture|
          lecture.should be_blocked
        end
      end
    end
  end
end
