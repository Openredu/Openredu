# -*- encoding : utf-8 -*-
class FoldersController < BaseController
  check_authorization

  load_and_authorize_resource :space
  load_and_authorize_resource :folder, :through => :space,
    :through_association => :folders_and_subfolders

  before_filter :load_course_and_environment

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.js { render :error_quota }
    end
  end

  # FILE
  def destroy_file
    @myfile = Myfile.find(params[:file_id], :include => :folder)
    service = MyfileService.new(:model => @myfile)
    service.destroy

    respond_to do |format|
      format.html do
        flash[:notice] = 'Arquivo removido!'
        redirect_to space_folders_path(:id => @folder.id,
                                       :space_id => @space.id)
      end
      format.js do
        list
        render :partial => 'folders/index'
      end
    end
  end

  # Upload the file and create a record in the database.
  # The file will be stored in the 'current' folder.
  def do_the_upload
    authorize! :upload_file, @folder

    service = MyfileService.new(params[:myfile])
    @myfile = service.create do |myfile|
      myfile.user = current_user
    end

    respond_to do |format|
      format.html { redirect_to @space }
      format.js do
        list
        render :do_the_upload
      end
    end
  end

  def download
    @myfile = Myfile.find(params[:file_id])

    if  @myfile
        send_file @myfile.attachment.path, :type=> @myfile.attachment.content_type
    else
        flash[:error] = "Você não tem permissão para baixar o arquivo."
        redirect_to user_path(current_user)
    end
  end

  # FOLDER
  # The default action, redirects to list.
  def index
    list(params[:id])

    respond_to do |format|
      format.html
      format.js { render :partial => "folders/index" }
    end
  end

  # Create a new folder with the posted variables from the 'new' view.
  def create
    folder_service = FolderService.new(params[:folder])
    @folder = folder_service.create do |folder|
      folder.user = current_user
      folder.date_modified = Time.now
    end

    respond_to do |format|
      if @folder.valid?
        list(@folder.id)
        flash[:notice] = 'Diretório criado!'
      else
        flash[:error] = 'Não foi possível criar o diretório'
      end

      format.html do
        redirect_to space_folders_path(@space, :id => @folder.parent)
      end
      format.js
    end
  end

  # Update the folder attributes with the posted variables from the 'rename' view.
  def update
    folder_attrs = params[:folder].merge(:date_modified => Time.now)
    folder_service = FolderService.new(:model => @folder)

    if folder_service.update(folder_attrs)
      respond_to do |format|
        format.js { list @folder.parent_id }
      end
    end
  end

  # Delete a folder.
  def destroy_folder
    options = { :model => @folder }

    folder_service = FolderService.new(options)
    folder_service.destroy

    respond_to do |format|
      # back to the list
      format.js {
        list @folder.parent_id
      }
    end

  end

  private

  # List the files and sub-folders in a folder.
  def list(id=nil)
    # Get the folder
    if id
      @folder = Folder.find(id)
    else
      @folder = @space.root_folder
      @folder = @myfile.folder if @myfile
    end

    @myfile ||= Myfile.new

    # Set if the user is allowed to update or delete in this folder;
    # these instance variables are used in the view.
    @can_update = current_ability.can?(:upload_file, @folder)
    @can_delete = @can_update

    # determine the order in which files are shown
    file_order = 'attachment_file_name '
    if params[:order_by]
      file_order = params[:order_by].sub('name', 'attachment_file_name') + ' ' if params[:order_by] == 'name'
      file_order = params[:order_by].sub('filesize', 'attachment_file_size') + ' ' if params[:order_by] == 'filesize'
      file_order = params[:order_by].sub('date_modified', 'attachment_updated_at') + ' ' if params[:order_by] == 'date_modified'
    end
    file_order += params[:order] if params[:order]

    # determine the order in which folders are shown
    folder_order = 'name '
    if params[:order_by] and params[:order_by] != 'filesize'
      folder_order = params[:order_by] + ' '
      folder_order += params[:order] if params[:order]
    end

    @files_count = Myfile.includes(:folder).where('folders.space_id' => @space.id).count
    bytes = Myfile.includes(:folder).where('folders.space_id' => @space.id).
      sum(:attachment_file_size)
    @total_size = "%0.2f" % (bytes / (1024.0 * 1024));
    gigabytes = 2
    @use_percentage = "%0.2f" % (bytes / ( gigabytes * 1024.0 * 1024.0 * 1024.0))

    # List of subfolders
    @folders = @folder.list_subfolders(current_user, folder_order.rstrip)

    # List of files in the folder
    @myfiles = @folder.list_files(current_user, file_order.rstrip)
  end

  def load_course_and_environment
    @course = @space.course
    @environment = @course.environment
  end
end
