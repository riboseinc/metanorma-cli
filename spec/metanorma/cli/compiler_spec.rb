require "spec_helper"

RSpec.describe Metanorma::Cli::Compiler do
  describe ".compile" do
    it "compile a document to desire formats" do
      compiler = double("Metanorma::Compile", compile: nil, errors: [])
      allow(Metanorma::Compile).to receive(:new).and_return(compiler)

      Metanorma::Cli::Compiler.compile(sample_asciidoc_file, attributes)

      expect(compiler).to have_received(:compile).with(
        sample_asciidoc_file, attributes
      )
    end

    # @TODO: What exactly are we testing here?
    # The script should exit with non zero status when errors lake following occur:
    #   [metanorma] Error: xmlrfc2 format is not supported for this standard.
    #   [metanorma] Error: nits format is not supported for this standard.
    # See issue 151.
    #
    it "compile with errors" do
      # skip "seems like it's breaking the test suite"
      # Try to update metanorma gem

      expect do
        Metanorma::Cli.start(["spec/fixtures/draft-gold-acvp-sub-kdf135-x942.adoc"])
      end.to raise_error SystemExit

      delete_file_if_exist("draft-gold-acvp-sub-kdf135-x942.err")
      delete_file_if_exist("draft-gold-acvp-sub-kdf135-x942.rfc.xml")
      delete_file_if_exist("draft-gold-acvp-sub-kdf135-x942.")
    end

    it "write files to specified output dir" do
      Metanorma::Cli.start(["spec/fixtures/sample-file.adoc", "-o", "spec/assets"])
      expect(File.exist?("spec/assets/sample-file.html")).to be true
      expect(File.exist?("spec/assets/sample-file.xml")).to be true
      expect(File.exist?("spec/assets/sample-file.presentation.xml")).to be true
      Dir["spec/assets/sample-file.*"].each { |f| File.delete f }
    end
  end

  def attributes
    {
      type: "iso",
      extract_type: [],
      extension_keys: [],
    }
  end

  def sample_asciidoc_file
    @sample_asciidoc_file ||=
      Metanorma::Cli.root_path.
      join("spec", "fixtures", "sample-file.adoc").to_s
  end

  def delete_file_if_exist(filename)
    filepath = Metanorma::Cli.root_path.join("spec", "fixtures", filename).to_s
    File.delete(filepath) if File.exists?(filepath)
  end
end
