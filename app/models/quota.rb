# -*- encoding : utf-8 -*-
class Quota < ActiveRecord::Base
  belongs_to :billable, :polymorphic => true

  # Atualiza na Quota a quantidade de bytes utilizados pelo billable
  # quota.refresh!
  # => true
  def refresh!
    courses = if self.billable.is_a? Environment
                self.billable.courses
              else
                self.billable
              end

    multimedia_size = self.calculate_seminars_size(courses)
    files_size = self.calculate_files_size(courses) +
      self.calculate_documents_size(courses)
    self.update_attributes(:multimedia => multimedia_size, :files => files_size)
  end

  # Calcula a quantidade de bytes utilizados por MyFile nos cursos
  # quota.calculate_files_size(courses)
  # => 3300411
  def calculate_files_size(courses)
    myfiles = Myfile.find_by_sql(["SELECT IFNULL(SUM(IFNULL(m.attachment_file_size, 0)), 0)" \
                                  " as attachment_file_size" \
                                  " FROM spaces s LEFT JOIN folders f ON s.id = f.space_id" \
                                  " LEFT JOIN myfiles m ON f.id = m.folder_id" \
                                  " WHERE s.course_id IN (?)", courses])
    myfiles[0].attachment_file_size
  end

  # Calcula a quantidade de bytes utilizados por Seminar nos cursos
  # quota.calculate_seminars_size(courses)
  # => 3300411
  def calculate_seminars_size(courses)
    seminars = Seminar.find_by_sql(["SELECT IFNULL((" \
                                    "SUM(IFNULL(se.original_file_size, 0))" \
                                    " + SUM(IFNULL(se.media_file_size, 0))), 0)" \
                                    " AS original_file_size FROM spaces s" \
                                    " LEFT JOIN subjects su ON su.space_id = s.id" \
                                    " LEFT JOIN lectures l ON l.subject_id = su.id" \
                                    " LEFT JOIN seminars se ON l.lectureable_id = se.id" \
                                    " where l.lectureable_type = 'Seminar'" \
                                    " AND su.finalized = 1 " \
                                    " AND s.course_id IN (?)", courses])
    seminars[0].original_file_size
  end

  # Calcula a quantidade de bytes utilizados por Document nos cursos
  # quota.calculate_documents_size(courses)
  # => 3300411
  def calculate_documents_size(courses)
    documents = Document.find_by_sql(["SELECT IFNULL(" \
                                      "SUM(IFNULL(d.attachment_file_size, 0)), 0)" \
                                      " AS attachment_file_size FROM spaces s" \
                                      " LEFT JOIN subjects su ON su.space_id = s.id" \
                                      " LEFT JOIN lectures l ON l.subject_id = su.id" \
                                      " LEFT JOIN documents d ON l.lectureable_id = d.id" \
                                      " WHERE l.lectureable_type LIKE 'Document'" \
                                      " AND su.finalized = 1 " \
                                      " AND s.course_id IN (?)", courses])
    documents[0].attachment_file_size
  end
end
