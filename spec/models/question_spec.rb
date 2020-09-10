# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Question do
  subject { FactoryBot.create(:question) }

  it { should have_many(:alternatives).dependent(:destroy) }
  it { should belong_to(:exercise) }
  it { should have_one(:correct_alternative) }
  it { should validate_presence_of(:statement) }
  it { should have_many(:choices).dependent(:destroy) }
  it { should accept_nested_attributes_for(:alternatives) }
  it { should have_attached_file(:image) }

  context "when validating alternatives count" do
    it "should add error when the question has just one alternative" do
      subject = FactoryBot.create(:complete_question)
      subject.alternatives[0].destroy
      subject.alternatives[1].destroy

      subject.reload.make_sense?
      subject.errors[:base].should_not be_empty
    end

    it "should add error when there are alternatives makerd for destruction" do
      subject = FactoryBot.create(:complete_question)
      alt1, alt2 = subject.alternatives[0], subject.alternatives[1]
      mass = { :alternatives_attributes => {
        "1" => { :id => alt1.id, :_destroy => true, :text => "my def text" },
        "2" => { :id => alt2.id, :_destroy => true, :text => "my def text" }} }

      subject.attributes = mass
      subject.make_sense?.should_not be_true
    end
  end

  context "when validating uniqueness of correct alternative" do
    subject { FactoryBot.create(:complete_question) }
    let(:alternatives) { subject.alternatives }

    it "should validate when more than 2 correct" do
      mass = alternatives.collect(&:attributes).collect { |a|
        a["correct"] = true
        a
      }
      subject.attributes = { :alternatives_attributes => mass }
      subject.should_not be_valid
      subject.errors[:alternatives].should_not be_empty
    end
  end

  context "sortable" do
    before do
      subject.exercise = FactoryBot.create(:exercise)
    end

    it "should respond to next_item" do
      [:next_item, :previous_item, :position].each do |method|
        subject.should respond_to(method)
      end
    end
  end

  context "when responding" do
    before do
      @alternatives = 3.times.collect {
        FactoryBot.create(:alternative, :question => subject, :correct => false)
      }
      @alternatives.first.update_attribute(:correct, true)
      @user = FactoryBot.create(:user)
    end

    it "should respond to choose_alternative" do
      subject.should respond_to(:choose_alternative)
    end

    it "should choose alternative" do
      expect {
        subject.choose_alternative(@alternatives.first, @user)
      }.to change(Choice, :count).by(1)
    end

    it "should choose alternative when passing an ID" do
      alt_id = @alternatives.first.id

      expect {
        subject.choose_alternative(alt_id, @user)
      }.to change(Choice, :count).by(1)
    end

    it "should assign the user" do
      choice = subject.choose_alternative(@alternatives.first, @user)
      choice.user.should == @user
    end

    it "should assign correctness when correct choice" do
      choice = subject.choose_alternative(@alternatives.first, @user)
      choice.correct.should be_true
    end

    it "should assign correctness when wrong choice" do
      choice = subject.choose_alternative(@alternatives.last, @user)
      choice.correct.should be_false
    end
  end

  context "when responding again" do
    before do
      @alternatives = 3.times.collect {
        FactoryBot.create(:alternative, :question => subject, :correct => false)
      }
      @alternatives.first.update_attribute(:correct, true)
      @user = FactoryBot.create(:user)
    end

    it "should not create another choice" do
      subject.choose_alternative(@alternatives.last, @user)
      expect {
        subject.choose_alternative(@alternatives.first, @user)
      }.to_not change(Choice, :count)
    end

    it "should update the choice" do
      choice = subject.choose_alternative(@alternatives.first, @user)
      new_choice = subject.choose_alternative(@alternatives.last, @user)

      new_choice.should == choice
      new_choice.correct.should be_false
    end
  end

  context "when trying to get the choice" do
    before do
      @alternatives = 3.times.collect {
        FactoryBot.create(:alternative, :question => subject, :correct => false)
      }
      @alternatives.first.update_attribute(:correct, true)
      @user = FactoryBot.create(:user)
    end

    it "returns nil if there is no choice" do
      subject.choice_for(@user).should be_nil
    end

    it "return the choice if it already exists" do
      choice = subject.choose_alternative(@alternatives.first, @user)
      subject.choice_for(@user).should == choice
    end
  end

  context "when accepting nested attributes" do
    before do
      @question = FactoryBot.build(:question)
    end
    context "when creating a question with blank alternatives" do
      before do
        alternatives_attrs =  {
          :alternatives_attributes => {
          "1" => { :text => "Lorem 1", :correct => "0"},
          "2" => { :text => "Lorem 2", :correct => "0"},
          "3" => { :text => "Lorem 3", :correct => "0"},
          "4" => {:text => "Lorem correct", :correct => "1"},
          "5" => {:text => "", :correct => "0"},
          "6" => {:text => "", :correct => "0"}
          }
        }
        @question.attributes = alternatives_attrs
      end

      it "question is valid" do
        @question.should be_valid
      end

      it "saves the question" do
        expect {
          @question.save
        }.to change(Question, :count).by(1)
      end

      it "saves only the complete alternatives" do
        expect {
          @question.save
        }.to change(Alternative, :count).by(4)
      end
    end

    context "when creating a question with correct alternative with blank text" do
      before do
        alternatives_attrs =  {
          :alternatives_attributes => {
            "1" => { :text => "Lorem 1", :correct => "0" },
            "3" => { :text => "Lorem 3", :correct => "0" },
            "4" => { :text => "", :correct => "1" }
          }
        }
        @question.attributes = alternatives_attrs
      end

      it "it is not valid" do
        @question.should_not be_valid
      end

      it "alternative with blank text it is not valid" do
        @question.alternatives.find { |a| a.text.blank? }.should_not be_valid
      end
    end
  end

  context "when acting as a list" do
    it "should include SimpleActsAsList::ModelAdditions" do
      Lecture.should include(SimpleActsAsList::ModelAdditions)
    end

    # Just to be sure that simple_acts_as_list was called
    it { should respond_to :last_item? }
  end
end
