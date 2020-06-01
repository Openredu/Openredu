# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'authlogic/test_case'

describe LecturesController do
  before do
    @space = FactoryGirl.create(:space)
    @subject_owner = FactoryGirl.create(:user)
    @space.course.join @subject_owner, Role[:teacher]

    @subject = FactoryGirl.create(:subject, :owner => @subject_owner,
                       :space => @space, :finalized => true,
                       :visible => true)
    @lectures = (1..3).collect { FactoryGirl.create(:lecture,:subject => @subject ,
                                         :owner => @subject_owner) }
    @enrolled_user = FactoryGirl.create(:user)
    @space.course.join @enrolled_user
    @subject.enroll @enrolled_user
    login_as @enrolled_user
  end

  context "when GET 'show'" do
    context "when Page" do
      before do
        post :show, :locale => "pt-BR", :id => @lectures[0].id,
          :subject_id => @subject.id, :space_id => @space.id
      end

      it "renders show_page" do
        response.should render_template('lectures/show_page')
      end
    end

    context "when Seminar" do
      before do
        lectureable = @lectures[0].lectureable
        #lectureable = FactoryGirl.create(:seminar)
        lectureable.save
        post :show, :locale => "pt-BR", :id => @lectures[0].id,
          :subject_id => @subject.id, :space_id => @space.id
      end
    end

    context "when Document" do
      before do
        @lectures[0].lectureable = FactoryGirl.create(:document)
        @lectures[0].save
        post :show, :locale => "pt-BR", :id => @lectures[0].id,
          :subject_id => @subject.id, :space_id => @space.id
      end
    end

    context "when Exercise" do
      before do
        @exercise = FactoryGirl.create(:complete_exercise)
        @lectures[0].lectureable = @exercise
        @lectures[0].save

        get :show, :locale => "pt-BR", :id => @lectures[0].id,
          :subject_id => @subject.id, :space_id => @space.id
      end

      it "assigns the exercise" do
        assigns[:lecture].should_not be_nil
        assigns[:lecture].lectureable.should == @exercise
      end

      it "renders ther correct template" do
        response.should render_template('lectures/show_exercise')
      end
    end
  end

  context "POST 'done'" do
    context "when done = 1" do
      it "marks the actual lecture as done" do
        post :done, :locale => "pt-BR", :id => @lectures[0].id,
          :subject_id => @subject.id, :space_id => @space.id, :done => "1"

        @lectures[0].asset_reports.of_user(@enrolled_user).last.
          should be_done
      end
    end

    context "when done = 0" do
      it "marks the actual lecture as undone" do
        @lectures[0].asset_reports.of_user(@enrolled_user).last.done = true

        post :done, :locale => "pt-BR", :id => @lectures[0].id,
          :subject_id => @subject.id, :space_id => @space.id, :done => "0"

        @lectures[0].asset_reports.reload.of_user(@enrolled_user).last.
          should_not be_done
      end
    end

    it "should call update_grade! and update the grade" do
      post :done, :locale => "pt-BR", :id => @lectures[0].id,
        :subject_id => @subject.id, :space_id => @space.id, :done => "1"
      @enrolled_user.enrollments.first.grade.should == 33.3333
    end

    it "should assign student_grade" do
      post :done, :locale => "pt-BR", :id => @lectures[0].id,
        :subject_id => @subject.id, :space_id => @space.id, :done => "1"
      assigns[:student_grade].should_not be_nil
    end

    it "should reload the enrollment (student_profile)" do
      enrollment = mock_model(Enrollment)
      @enrolled_user.enrollments.stub(:where).and_return([enrollment])
      enrollment.stub(:update_grade!)

      enrollment.should_receive(:reload).and_return(enrollment)

      post :done, :locale => "pt-BR", :id => @lectures[0].id,
        :subject_id => @subject.id, :space_id => @space.id, :done => "1"
    end

    context 'when html request' do
      it "redirects to lecture show" do
        post :done, :locale => "pt-BR", :id => @lectures[0].id,
          :subject_id => @subject.id, :space_id => @space.id

        response.should redirect_to(
          controller.space_subject_lecture_path(@space, @subject, @lectures[0]))
      end
    end

    context 'when js request' do
      it "renders done.rjs" do
        post :done, :locale => "pt-BR", :id => @lectures[0].id, :format => 'js',
          :subject_id => @subject.id, :space_id => @space.id

        response.should render_template('lectures/done')
      end
    end
  end

  context "admin panel" do
    before do
      login_as @subject_owner
    end

    context "GET new" do
      before do
        get :new, :locale => "pt-BR", :format => "js",
          :space_id => @space, :subject_id => @subject, :type => "Page"
      end

      it "assigns a lecture" do
        assigns[:lecture].should_not be_nil
      end

      it "assigns a lecture with a lectureable (Page)" do
        lectureable = assigns[:lecture].lectureable
        lectureable.should_not be_nil
        lectureable.should be_kind_of(Page)
      end
    end

    context "POST create (Page)" do
      before do
        @post_params = { :locale => "pt-BR", :format => "js" }
        @post_params.merge!({ :space_id => @space, :subject_id => @subject,
                              :lecture => { :name => "Cool lecture",
                                            :lectureable_attributes => {
                                              :_type => "Page",
                                              :a123a231 => { :body => "Bunch of words." }
                                            } } })
      end

      it_should_behave_like 'created lecture' do
        let(:lectureable_class) { Page }
        let(:create_params) { @post_params }
      end
    end

    context "GET new (Exercise)" do
      before do
        get :new, :locale => "pt-BR", :format => "js",
          :space_id => @space, :subject_id => @subject, :type => "Exercise"
      end

      it "assigns lecture" do
        assigns[:lecture].should_not be_nil
      end

      it "builds a lecture" do
        assigns[:lecture].lectureable.is_a?(Exercise).should be_true
      end

      it "builds a lecture within a question" do
        assigns[:lecture].lectureable.questions.should_not be_empty
      end

      it "builds a question within an alternative" do
        assigns[:lecture].lectureable.questions.first.alternatives.
          should_not be_empty
      end
    end

    context "POST create (Exercise)" do
      before do
        @alternatives = {
         "1" => {:text => "Lorem ipsum dolor4", :correct => true},
         "2" => {:text => "Lorem ipsum dolor5"},
         "3" => {:text => "Lorem ipsum dolor6"}
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

        @params = { :locale => 'pt-BR', :format => 'js', :space_id => @space.id,
                    :subject_id => @subject.id }
        @params.merge!(:lecture =>
                       { :name => "Cool lecture",
                         :lectureable_attributes =>
                       { :_type => 'Exercise',
                         :questions_attributes => @questions }})
      end

      it_should_behave_like 'created lecture' do
        let(:lectureable_class) { Exercise }
        let(:create_params) { @params }
      end
    end

    context "POST create invalid (Exercise)" do
      before do
        # Apenas uma alternativa por questão
        @alternatives = {
          "1" => {:text => "Lorem ipsum dolor", :correct => true}
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
        
        @params = { :locale => 'pt-BR', :format => 'js', :space_id => @space.id,
                    :subject_id => @subject.id }
        @params.merge!(:lecture =>
                       { :name => "Cool lecture",
                         :lectureable_attributes =>
                       { :_type => 'Exercise',
                         :questions_attributes => @questions }})
      end

      it "should not create the Exercise" do
        expect {
          post :create, @params
        }.to_not change(Exercise, :count).by(1)
      end

      it "should validate correctly" do
        post :create, @params
        lecture = assigns[:lecture]
        lecture.lectureable.questions[0].errors[:base].should_not be_empty
      end

      context "when exercise does not have questions" do
        before do
          @params[:lecture][:lectureable_attributes][:questions_attributes] = {}
          post :create, @params
        end

        it "assigns @lecture (Exercise) with one question" do
          assigns[:lecture].lectureable.questions.should_not be_empty
        end

        it "assigns @lecture (Exercise) with one question" do
          assigns[:lecture].lectureable.questions.should have(1).item
        end
      end
    end

    context "POST update (Exercise)" do
      subject { FactoryGirl.create(:lecture,
                        :lectureable => FactoryGirl.create(:complete_exercise),
                        :subject => @subject ) }

      before do
        @params = { :locale => 'pt-BR', :format => 'js', :space_id => @space.id,
                    :subject_id => @subject.id, :id => subject.id }
        @questions = subject.lectureable.questions.collect do |q|
          alternatives = {}
          q.alternatives.each_with_index {|a, i| alternatives[i] = a.attributes }
          { :id => q.id, :statement => "new statement",
            :alternatives_attributes => alternatives }
        end

        @params.merge!(:lecture =>
                       { :name => "Cool lecture",
                         :lectureable_attributes =>
                       { :_type => 'Exercise',
                         :id => subject.lectureable.id,
                         :questions_attributes => @questions }})
      end

      it "updates the lecture" do
        expect {
          post :update, @params
        }.to change { subject.lectureable.questions.first.reload.statement }.
          to("new statement")
      end

      it "should remove the alternative when destroy => true is passed" do
        @params[:lecture][:lectureable_attributes][:questions_attributes].
          first[:alternatives_attributes].values.last["_destroy"] = true
        expect {
          post :update, @params
        }.to change(Alternative, :count).by(-1)
      end
    end

    context "POST update (Exercise) invalid" do
      subject { FactoryGirl.create(:lecture,
                        :lectureable => FactoryGirl.create(:complete_exercise),
                        :subject => @subject ) }

      before do
        @params = { :locale => 'pt-BR', :format => 'js', :space_id => @space.id,
                    :subject_id => @subject.id, :id => subject.id }
        @questions = subject.lectureable.questions.collect do |q|
          alternatives = {}
          q.alternatives.each_with_index {|a, i| alternatives[i] = a.attributes }
          { :id => q.id, :statement => "new statement",
            :alternatives_attributes => alternatives }
        end

        @params.merge!(:lecture =>
                       { :name => "Cool lecture",
                         :lectureable_attributes =>
                       { :_type => 'Exercise',
                         :id => subject.lectureable.id,
                         :questions_attributes => @questions }})
      end

      context "when exercise has a question without alternatives" do
        before do
          @params[:lecture][:lectureable_attributes][:questions_attributes] << {
            :statement => "new question",
            :alternatives_attributes => {}
          }
          post :update, @params
        end

        it "assigns @lecture (Exercise) where last question has one alternative" do
          assigns[:lecture].lectureable.questions.last.alternatives.
            should have(1).item
        end
      end
    end

    context "POST update" do
      before do
        @lecture = @subject.lectures.first
        @post_params = { :locale => "pt-BR", :format => "js" }
        @post_params.merge!({ :space_id => @space, :subject_id => @subject,
                              :id => @lecture,
                              :lecture => { :name => "Cool lecture",
                                            :lectureable_attributes => {
                                              :id => @lecture.lectureable.id,
                                              :_type => "Page",
                                              :body => "Bunch of words."} } })
        post :update, @post_params
      end

      it "updates a lecture" do
        @lecture.reload.name.should == @post_params[:lecture][:name]
      end

      it "updates a lectureable (Page)" do
        @lecture.lectureable.reload.body.should ==
          @post_params[:lecture][:lectureable_attributes][:body]
      end
    end
    end
end
