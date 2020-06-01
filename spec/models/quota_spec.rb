# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Quota do
  subject { FactoryGirl.create(:quota) }

  it { should belong_to(:billable) }

  context "when updating quotas" do

    it "responds to update_for" do
      should respond_to(:refresh!)
    end

    context "updates quotas successfully" do
      before do
        @environment = FactoryGirl.create(:environment)
        @courses = (1..3).collect do
          c = FactoryGirl.create(:course, :environment => @environment)
          (1..3).each { FactoryGirl.create(:space, :course => c) }
          c.reload
        end
        @environment.reload
      end

      def create_uploadable_objects_in(spaces)
          files = spaces.collect do |s|
            FactoryGirl.create(:myfile, :folder => s.folders.first,
                    :attachment_file_size => 2.megabytes)
          end

          seminars = spaces.collect do |s|
            sub = FactoryGirl.create(:subject, :space => s, :finalized => true)

            (1..3).collect do
              seminar = FactoryGirl.create(:seminar_upload,
                                :original_file_size => 3.megabytes)
              FactoryGirl.create(:lecture, :subject => sub, :lectureable => seminar)
              seminar
            end
          end
          seminars.flatten!

          documents = spaces.collect do |s|
            sub = FactoryGirl.create(:subject, :space => s, :finalized => true)

            (1..3).collect do
              doc = FactoryGirl.create(:document, :attachment_file_size => 1.megabytes)
              FactoryGirl.create(:lecture, :subject => sub, :lectureable => doc)
              doc
            end
          end
          documents.flatten!

          spaces.collect do |s|
            sub = FactoryGirl.create(:subject, :space => s)

            seminar = FactoryGirl.create(:seminar_upload,
                              :original_file_size => 3.megabytes)
            doc = FactoryGirl.create(:document, :attachment_file_size => 1.megabytes)

            FactoryGirl.create(:lecture, :subject => sub, :lectureable => seminar)
            FactoryGirl.create(:lecture, :subject => sub, :lectureable => doc)
          end

          { :files => files.collect(&:attachment_file_size).sum,
            :seminars => seminars.collect(&:original_file_size).sum,
            :documents => documents.collect(&:attachment_file_size).sum }
      end

      context "when billable is a course" do
        let(:subject) { FactoryGirl.create(:unused_quota, :billable => @courses.first) }

        before do
          @spaces = @courses.first.spaces

          sizes = create_uploadable_objects_in(@spaces)

          @updated_files_size = sizes[:files]
          @updated_seminars_size = sizes[:seminars]
          @updated_documents_size = sizes[:documents]
        end

        it "should calculate uploaded files size" do
          subject.calculate_files_size(@courses.first).
            should == @updated_files_size
        end

        it "should calculate uploaded seminars size" do
          subject.calculate_seminars_size(@courses.first).
            should == @updated_seminars_size
        end

        it "should calculate uploaded documents size" do
          subject.calculate_documents_size(@courses.first).
            should == @updated_documents_size
        end

        it "should update multimedia files value" do
          expect {
            subject.refresh!
          }.to change { subject.multimedia }.from(0).to(@updated_seminars_size)
        end

        it "should update quota files value" do
          total_files_size = @updated_files_size + @updated_documents_size
          expect {
            subject.refresh!
          }.to change { subject.files }.from(0).to(total_files_size)
        end

      end

      context "when billable is a environment" do
        let(:subject) { FactoryGirl.create(:unused_quota, :billable => @environment) }

        before do
          @courses = @environment.courses
          @spaces = @courses.collect(&:spaces).flatten

          sizes = create_uploadable_objects_in(@spaces)

          @updated_files_size = sizes[:files]
          @updated_seminars_size = sizes[:seminars]
          @updated_documents_size = sizes[:documents]
        end

        it "should calculate uploaded files size" do
          subject.calculate_files_size(@courses).
            should == @updated_files_size
        end

        it "should calculate uploaded seminars size" do
          subject.calculate_seminars_size(@courses).
            should == @updated_seminars_size
        end

        it "should calculate uploaded documents size" do
          subject.calculate_documents_size(@courses).
            should == @updated_documents_size
        end

        it "should update multimedia files value" do
          expect {
            subject.refresh!
          }.to change { subject.multimedia }.from(0).to(@updated_seminars_size)
        end

        it "should update quota files value" do
          total_files_size = @updated_files_size + @updated_documents_size
          expect {
            subject.refresh!
          }.to change { subject.files }.from(0).to(total_files_size)
        end

      end
    end
  end
end
