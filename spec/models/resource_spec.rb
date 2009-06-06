require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Resource do
  before(:each) do
    @user = User.create!
    @project = Project.create!(:name => 'Test Project', :user => @user)
  end

  describe "with content passed directly" do
    before(:each) do
      @resource = Resource.new(
         'chapters/main.tex',
         nil,
         'Test content',
         nil,
         @project
      )
    end

    it "should write the file to disk in the compile directroy" do
      @resource.write_to_disk
      file_path = File.join(LATEX_COMPILE_DIR, @project.unique_id, 'chapters/main.tex')
      File.exist?(file_path).should be_true
      File.read(file_path).should eql 'Test content'
      FileUtils.rm_r(File.join(LATEX_COMPILE_DIR, @project.unique_id))
    end

    it "should return the content passed directly" do
      @resource.content.should eql 'Test content'
    end
  end

  describe "with content taken from an URL" do
    before(:each) do
      @resource = Resource.new(
         'chapters/main.tex',
         nil,
         nil,
         'http://www.example.com/main.tex',
         @project
      )
    end
    
    it "should return the content from the URL" do
      Utilities.should_receive(:get_content_from_url).with('http://www.example.com/main.tex').and_return('URL content')
      @resource.content.should eql 'URL content'
    end
  end

  describe "with a path that tries to break out of the compile directory" do
    before(:each) do
      @resource = Resource.new(
         '../../main.tex',
         nil,
         'Content',
         nil,
         @project
      )
    end

    it "should raise a CLSI::InvalidPath error when writen to disk" do
      lambda{
        @resource.write_to_disk
      }.should raise_error(CLSI::InvalidPath, 'path is not inside the compile directory')
    end
  end
end