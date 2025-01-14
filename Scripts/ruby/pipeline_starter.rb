require_relative 'pipelines/download_middleware'
require_relative 'pipelines/version_provider'
require_relative 'pipelines/copy_artifacts_pipeline'
require_relative 'library/lib_version'

class PipelineStarter
  def self.start(options)

    unless options[:artifactsPath].empty?
      install_library_from_path(options)
      return
    end

    if options[:latest]
      install_latest_library(options)
      return
    end

    if options[:version]
      install_specific_version_library(options)
      return
    end

    install_library_from_libfile(options)
  end

  private_class_method def self.install_library_from_path(options)
      path = options[:artifactsPath]
      puts "Install library from path #{path}"
      CopyArtifactsPipeline.work(path)
      done()
  end

  private_class_method def self.install_latest_library(options)
    version = VersionProvider.latest_version(options[:token])
    actifacts_dir = DownloadMiddlewarePipeline.work(version, options)
    
    CopyArtifactsPipeline.work(actifacts_dir)

    LibraryFile.set(version)
    
    cleanup(actifacts_dir)
    done()
  end


  private_class_method def self.install_specific_version_library(options)
    version = VersionProvider.specific_version(options[:version], options[:token])
    actifacts_dir = DownloadMiddlewarePipeline.work(version, options)
    
    CopyArtifactsPipeline.work(actifacts_dir)

    LibraryFile.set(version)
    
    cleanup(actifacts_dir)
    done()
  end

  private_class_method def self.install_library_from_libfile(options)
    version = VersionProvider.version_from_library_file(options[:token])
    actifacts_dir = DownloadMiddlewarePipeline.work(version, options)
    
    CopyArtifactsPipeline.work(actifacts_dir)

    cleanup(actifacts_dir)
    done()
  end

  private_class_method def self.cleanup(dir)
    puts "Cleaning up artifacts"
    FileUtils.remove_entry dir
  end

  private_class_method def self.done
    puts "Done 💫".red.blink
    `afplay /System/Library/Sounds/Glass.aiff`
  end
end