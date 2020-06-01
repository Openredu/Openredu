# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Lecture do
  before do
    environment = FactoryGirl.create(:environment)
    course = FactoryGirl.create(:course, :owner => environment.owner,
                     :environment => environment)
    @space = FactoryGirl.create(:space, :owner => environment.owner,
                     :course => course)
    @user = FactoryGirl.create(:user)
    course.join(@user)
    @sub = FactoryGirl.create(:subject, :owner => @user, :space => @space,
                   :finalized => true)
    @sub.enroll
  end

  subject { FactoryGirl.create(:lecture, :subject => @sub,
                    :owner => @sub.owner) }

  it { should belong_to :owner }
  it { should belong_to(:lectureable).dependent(:destroy) }

  it { should have_many(:logs) }
  it { should have_many(:statuses).dependent(:destroy) }

  it { should belong_to :subject }
  it { should accept_nested_attributes_for :lectureable }

  it { should validate_presence_of :name }
  it { should validate_presence_of :lectureable }

  it { should_not allow_mass_assignment_of :owner }
  it { should_not allow_mass_assignment_of :view_count }
  it { should_not allow_mass_assignment_of :is_clone }

  it "responds to mark_as_done_for!" do
    should respond_to :mark_as_done_for!
  end

  it "responds to done?" do
    should respond_to :done?
  end

  it "responds to recent?" do
    should respond_to :recent?
  end

  context "finders" do
    it "retrieves lectures that are seminars" do
      pending "Need seminar Factory" do
        seminars = (1..2).collect { FactoryGirl.create(:lecture,:subject => @sub,
                                            :lectureable => FactoryGirl.create(:seminar)) }
        FactoryGirl.create(:lecture, :subject => @sub)

        Lecture.seminars.should == seminars
      end
    end

    #FIXME não fazer teste com chamada a APIs externas
    xit "retrieves lectures that are pages" do
        page = FactoryGirl.create(:lecture, :subject => @sub)
        documents = (1..2).collect {
          FactoryGirl.create(:lecture, :subject => @sub,
                  :lectureable => FactoryGirl.create(:document)) }
        Lecture.pages.should == [page]
    end

    xit "retrieves lectures that are documents" do
        page = FactoryGirl.create(:lecture, :subject => @sub)
        documents = (1..2).collect {
          FactoryGirl.create(:lecture, :subject => @sub,
                  :lectureable => FactoryGirl.create(:document)) }

        Lecture.documents.should == documents
    end

    it "retrieves recent lectures (created until 1 week ago)" do
      lectures = (1..3).collect { |i| FactoryGirl.create(:lecture,
                                              :created_at => (i*3).day.ago) }
      Lecture.recent.should == lectures[0..1]
    end

    it "retrieves all editables exercises" do
      exercise1 = FactoryGirl.create(:exercise)
      lecture1 = FactoryGirl.create(:lecture, :subject => @sub,
                          :name => "Exercicio 1", :lectureable => exercise1)
      exercise2 = FactoryGirl.create(:exercise)
      lecture2 = FactoryGirl.create(:lecture, :subject => @sub,
                          :name => "Exercicio 2", :lectureable => exercise2)
      result = FactoryGirl.create(:result, :exercise => exercise1)

      Lecture.exercises_editables.should == [lecture2]
    end

    it "retrieve lectures in the specified subjects" do
      subject.reload
      lecture2 = FactoryGirl.create(:lecture, :subject => @sub, :owner => @user)
      sub2 = FactoryGirl.create(:subject)
      lecture3 = FactoryGirl.create(:lecture, :subject => sub2, :owner => @user)

      @user.lectures.by_subjects(@sub.id).to_set.should eq([subject, lecture2].to_set)
    end

    it "retrieves lectures by day" do
      subj = FactoryGirl.create(:subject)
      lec1 = FactoryGirl.create(:lecture, :subject => subj,
                     :created_at => "2012-02-14".to_date)
      lec2 = FactoryGirl.create(:lecture, :subject => subj,
                     :created_at => "2012-02-16".to_date)
      lectures = Lecture.by_subjects(subj.id)

      lectures.by_day("2012-02-14".to_date).should eq([lec1])
    end
  end

  context "being attended" do
    context "when done" do
      it "mark the current lecture as done" do
        subject_owner = FactoryGirl.create(:user)
        space = FactoryGirl.create(:space)
        space.course.join subject_owner
        subject1 = FactoryGirl.create(:subject, :owner => subject_owner,
                           :space => space)
        lectures = (1..3).collect { FactoryGirl.create(:lecture, :subject => subject1) }

        user = FactoryGirl.create(:user)
        subject1.enroll user

        lectures[0].mark_as_done_for!(user, true)
        lectures[0].asset_reports.of_user(user).last.
          should be_done
      end
    end

    context "when undone" do
      it "mark the current lecture as undone" do
        subject_owner = FactoryGirl.create(:user)
        space = FactoryGirl.create(:space)
        space.course.join subject_owner
        subject1 = FactoryGirl.create(:subject, :owner => subject_owner,
                           :space => space)
        lectures = (1..3).collect { FactoryGirl.create(:lecture, :subject => subject1) }

        user = FactoryGirl.create(:user)
        subject1.enroll user

        lectures[0].asset_reports.of_user(user).last.done = true
        lectures[0].mark_as_done_for!(user, false)
        lectures[0].asset_reports.of_user(user).last.
          should_not be_done
      end
    end
  end

  context "when generating a clone of itself" do
    before do
      subject_owner = FactoryGirl.create(:user)
      space = FactoryGirl.create(:space)
      space.course.join subject_owner
      @new_subject = FactoryGirl.create(:subject, :owner => subject_owner,
                         :space => space)
    end

    context "and itself is a page" do
      let(:subject) do
        FactoryGirl.create(:lecture, :subject => @sub, :owner => @sub.owner,
                :lectureable => FactoryGirl.create(:page))
      end

      before do
        @new_lecture = subject.clone_for_subject!(@new_subject.id)
      end

      it "generates a lecture differente of itself" do
        @new_lecture.should_not == subject
      end

      it "generates a clone" do
        @new_lecture.should be_is_clone
      end

      it "generates a clone that belongs to correct subject" do
        @new_lecture.subject.should == @new_subject
      end
    end

    context "and itself is a external seminar" do
      let(:subject) do
        FactoryGirl.create(:lecture, :subject => @sub, :owner => @sub.owner,
                :lectureable => FactoryGirl.create(:seminar_youtube))
      end

      before do
        @new_lecture = subject.clone_for_subject!(@new_subject.id)
      end

      it "generates a lecture differente of itself" do
        @new_lecture.should_not == subject
      end

      it "generates a clone" do
        @new_lecture.should be_is_clone
      end

      it "generates a clone that belongs to correct subject" do
        @new_lecture.subject.should == @new_subject
      end

      context "when clonning external resource url" do
        it "should be the same url" do
          @new_lecture.lectureable.external_resource_url.should == \
            subject.lectureable.external_resource_url
        end
      end
    end

    context "and itself is a exercise" do
      let(:subject) do
        FactoryGirl.create(:lecture, :subject => @sub, :owner => @sub.owner,
                :lectureable => FactoryGirl.create(:complete_exercise))
      end

      before do
        @new_lecture = subject.clone_for_subject!(@new_subject.id)
      end

      it "generates a lecture differente of itself" do
        @new_lecture.should_not == subject
      end

      it "generates a clone" do
        @new_lecture.should be_is_clone
      end

      it "generates a clone that belongs to correct subject" do
        @new_lecture.subject.should == @new_subject
      end

      context "when cloning questions" do
        it "generates a clone that contains all questions" do
          subject_q = attrs_except(subject.lectureable.questions,
                                   ["id","exercise_id", "created_at", "updated_at"])
          new_lecture_q = attrs_except(@new_lecture.lectureable.questions,
                                       ["id","exercise_id", "created_at", "updated_at"])

          subject_q.to_set.should == new_lecture_q.to_set
        end

        context "when cloning alternatives" do
          it "generates a clone that each question contain all alternatives" do
            subject_a = subject.lectureable.questions.collect do |q|
              attrs_except(q.alternatives, ["id","question_id", "created_at", "updated_at"])
            end

            new_lecture_a = @new_lecture.lectureable.questions.collect do |q|
              attrs_except(q.alternatives, ["id","question_id", "created_at", "updated_at"])
            end

            subject_a.to_set.should == new_lecture_a.to_set
          end
        end
      end
    end
  end


  context "#refresh_students_profile" do
    subject { FactoryGirl.create(:lecture, :subject => @sub, :owner => @sub.owner) }
    let(:enrollments) do
      FactoryGirl.create_list(:enrollment, 2, :subject => @sub)
    end
    let(:assets) do
      enrollments.map do |e|
        FactoryGirl.create(:asset_report, :lecture => subject,
                           :subject => @sub, :enrollment => e)
      end.flatten
    end

    before do
      assets.each do |asset|
        asset.done = 1
        asset.save
      end
    end

    it "should update all students profiles" do
      subject.refresh_students_profiles
      grade = enrollments.map(&:reload).map(&:grade)
      grade.should == [100, 100]

      subject.destroy
      subject.subject.reload
      subject.refresh_students_profiles
      grade = enrollments.map(&:reload).map(&:grade)
      grade.should == [0, 0]
    end
  end

  it "verifies if a lecture was done by a user" do
    subject_owner = FactoryGirl.create(:user)
    space = FactoryGirl.create(:space)
    space.course.join subject_owner
    subject1 = FactoryGirl.create(:subject, :owner => subject_owner,
                       :space => space)
    lectures = (1..3).collect { FactoryGirl.create(:lecture, :subject => subject1) }

    user = FactoryGirl.create(:user)
    subject1.enroll user

    lectures[0].done?(user).should be_false
  end

  it "indicates if it is recent (created until 1 week ago)" do
    subject.should be_recent

    subject.created_at = 10.day.ago
    subject.save
    subject.should_not be_recent
  end

  context "nested lectureable" do
    before do
      @owner = FactoryGirl.create(:user)
      @sub = FactoryGirl.create(:subject)
    end
    context "when valid" do
      before do
        @lecture = Lecture.new({ :name => "Name", :subject => @sub,
                                "lectureable_attributes" => {
                                  "_type" => "Page", "sadjaij1231" => { "body" => "Cool letters"}}})
        @lecture.owner = @owner
      end

      it "builds a lecture within a lectureable" do
        @lecture.should_not be_nil
        @lecture.lectureable.should_not be_nil
      end

      it "saves a lecture" do
        expect {
          @lecture.save
        }.to change(Lecture, :count).by(1)
      end

      it "saves a lectureable (Page)" do
        expect {
          @lecture.save
        }.to change(Page, :count).by(1)
      end
    end

    context "when invalid" do
      before do
        @lecture = Lecture.new({ :name => "Name", :subject => @sub,
                                 "lectureable_attributes" => {"_type" => "Page"}})
        @lecture.owner = @owner
      end

      it "builds a lecture within a lectureable" do
        @lecture.should_not be_nil
        @lecture.lectureable.should_not be_nil
      end

      it "validates lectureable" do
        @lecture.lectureable.should_not be_valid
      end

      it "does NOT save a lecture" do
        expect {
          @lecture.save
        }.to_not change(Lecture, :count)
      end

      it "does NOT save a lectureable (Page)" do
        expect {
          @lecture.save
        }.to_not change(Page, :count)
      end
    end


    context "when building attributes" do
      context "when Exercise" do
        before do
          @alternatives = {
            "1" => {:text => "Lorem ipsum dolor", :correct => true},
            "2" => {:text => "Lorem ipsum dolor"},
            "3" => {:text => "Lorem ipsum dolor"}
          }
          @questions = {
            '0' => { :statement => "Lorem ipsum dolor sit amet, consectetur?",
            :explanation => "Lorem ipsum dolor sit amet.",
            :alternatives_attributes => @alternatives.clone },
            '1' => { :statement => "Lorem ipsum dolor sit amet, consectetur?",
            :explanation => "Lorem ipsum dolor sit amet.",
            :alternatives_attributes => @alternatives.clone },
            '2' => { :statement => "Lorem ipsum dolor sit amet, consectetur?",
            :explanation => "Lorem ipsum dolor sit amet.",
            :alternatives_attributes => @alternatives.clone }
          }

          @params = { :lecture =>
                      { :name => "Cool lecture",
                        :lectureable_attributes =>
                      { :_type => 'Exercise',
                        :questions_attributes => @questions }}}
        end

        it "should build the Exercise" do
          lecture = Lecture.new(@params[:lecture])
          lecture.should be_valid
        end

        it "should create the Exercise" do
          expect {
            Lecture.create(@params[:lecture]) do |lecture|
            lecture.owner = @sub.owner
            lecture.subject = @sub
            end
          }.to change(Exercise, :count).by(1)
        end

        it "should return nil when there is not a _type" do
          subject.build_lectureable({}).should be_nil
        end

        it "should return nil when type is blank" do
          subject.build_lectureable({ :_type => '' }).should be_nil
        end
      end

      context "when Existent" do
        it "returns nil when type is Existent" do
          subject.build_lectureable({ :_type => 'Existent'}).should be_nil
        end
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

  describe "#finalized?" do
    let(:subj) { subject.subject }

    context "when subject is unfinalized" do
      before do
        subj.update_attribute(:finalized, false)
      end

      it "should not be finalized" do
        subject.should_not be_finalized
      end
    end

    context "when subject is finalized" do
      before do
        subj.update_attribute(:finalized, true)
      end

      it "should not be finalized if it's a new record" do
        subject = FactoryGirl.build(:lecture)
        subject.should_not be_finalized
      end

      it "should be finalized if it's persisted" do
        subject.save
        subject.should be_finalized
      end
    end
  end

  protected
  def attrs_except(entities, attrs_to_remove)
    entities.collect do |entity|
      attrs = entity.attributes

      attrs_to_remove.each do |attr|
        attrs.delete(attr)
      end
      attrs
    end
  end
end
