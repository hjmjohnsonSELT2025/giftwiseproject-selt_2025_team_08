class ContactsController < ApplicationController
  before_action :require_login
  before_action :set_contact, only: [:edit_note, :update_note, :destroy]

  def index
    @contacts = current_user.contact_users
    @contact_map = current_user.contacts.each_with_object({}) { |contact, map| map[contact.contact_user_id] = contact }
  end

  def new
    @users = User.available_for_contact(current_user)
  end

  def create
    contact_user_id = params[:contact_user_id]
    
    if contact_user_id.blank?
      redirect_to new_contact_path, alert: "Please select a contact"
      return
    end

    contact_user = User.find_by(id: contact_user_id)
    
    if contact_user.nil?
      redirect_to new_contact_path, alert: "User not found"
      return
    end

    @contact = current_user.contacts.build(contact_user: contact_user)

    if @contact.save
      redirect_to contacts_path, notice: "Contact added successfully"
    else
      redirect_to new_contact_path, alert: "Failed to add contact: #{@contact.errors.full_messages.join(', ')}"
    end
  end

  def edit_note
    render :edit_note, layout: false
  end

  def update_note
    if @contact.update(note: params[:contact][:note])
      respond_to do |format|
        format.js
        format.html { redirect_to contacts_path, notice: "Note updated successfully" }
      end
    else
      respond_to do |format|
        format.js
        format.html { render :edit_note, layout: false, status: :unprocessable_content }
      end
    end
  end

  def destroy
    @contact.destroy
    redirect_to contacts_path, notice: "Contact removed successfully"
  end

  def search
    query = params[:q].to_s.downcase
    contacts = current_user.contact_users.where("LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ?", "%#{query}%", "%#{query}%")
    
    render json: { contacts: contacts.map { |u| u.attributes.slice('id', 'first_name', 'last_name', 'occupation', 'hobbies', 'likes', 'dislikes', 'date_of_birth').merge(contact_user_id: u.id) } }
  end

  private

  def set_contact
    @contact = current_user.contacts.find(params[:id])
  end
end
