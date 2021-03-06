class PostsController < ApplicationController
  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @posts }
    end
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    @post = Post.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @post }
    end
  end

  # GET /posts/new
  # GET /posts/new.json
  def new

    # redirect to the register page if user tries to create a post when not logged in
    if !current_user
      redirect_to "/register"
    else

    @post = Post.new
    if params[:post_id]
      @post.post_id = params[:post_id]

      # The post being created as a reply/comment
      @replyPost = Post.find(params[:post_id])
      @replyPost.update_attribute :updated_at, Time.new.inspect
      @replyPost.save

      # Update the date updated of the parent post to sort the page correctly
      @parentPost = Post.find(Post.find(params[:post_id]).getParentPostID)
      @parentPost.update_attribute :updated_at, Time.new.inspect
      @parentPost.save
    end


    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @post }
    end
    end
  end

  # GET /posts/1/edit
  def edit
    @post = Post.find(params[:id])
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(params[:post])
    @post.user_id = current_user.id

    # If we are passing post_id as a parameter, this is a comment, not a parent post
    if params[:post_id]
      @post.post_id = params[:post_id]
    end

    if(@post.post_id)
      notice_text = 'Comment was successfully created.'
    else
      notice_text =  'Post was successfully created.'
    end

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: notice_text }
        format.json { render json: @post, status: :created, location: @post }
      else
        format.html { render action: "new" }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def vote

    vote = Vote.new
    vote.user_id = current_user.id
    vote.post_id = params[:post_id]

    # Update the updated_at for the parent post to sort page correctly
    @parentPost = Post.find(Post.find(params[:post_id]).getParentPostID)
    @parentPost.update_attribute :updated_at, Time.new.inspect
    @parentPost.save

    # if the vote already exists, then delete it, otherwise create it
    if vote.exists
      vote.delete
      redirect_to posts_path, notice: "You have removed your vote"
    else
      vote.save
      redirect_to posts_path, notice: "You have voted for this post"
    end

  end

  # PUT /posts/1
  # PUT /posts/1.json
  def update
    @post = Post.find(params[:id])

    # determine if its a comment or post by checking if parent post id exists
    if(@post.post_id)
      notice_text = 'Comment was successfully updated.'
    else
      notice_text =  'Post was successfully updated.'
    end

    respond_to do |format|
      if @post.update_attributes(params[:post])
        format.html { redirect_to @post, notice: notice_text }
      format.json { head :no_content }
      else
      format.html { render action: "edit" }
      format.json { render json: @post.errors, status: :unprocessable_entity }
    end
  end
end

# DELETE /posts/1
# DELETE /posts/1.json
def destroy
  @post = Post.find(params[:id])
  @post.destroy

  respond_to do |format|
    format.html { redirect_to posts_url }
      format.json { head :no_content }
    end
  end
end
