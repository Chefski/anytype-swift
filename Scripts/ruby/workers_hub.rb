require_relative 'workers/middleware/asset_url_worker'
require_relative 'workers/middleware/available_versions_worker'
require_relative 'workers/middleware/copy_artifacts_worker'
require_relative 'workers/middleware/copy_protobuf_worker'
require_relative 'workers/middleware/download_file_worker'
require_relative 'workers/middleware/library_version_worker'
require_relative 'workers/middleware/lockfile_version_worker'
require_relative 'workers/middleware/remote_info_worker'
require_relative 'workers/middleware/remote_version_worker'
require_relative 'workers/middleware/remove_directory_worker'
require_relative 'workers/middleware/compare_versions_worker'
require_relative 'workers/middleware/set_lockfile_version_worker'
require_relative 'workers/middleware/uncompress_file_worker'
require_relative 'workers/middleware/cleanup_worker'

require_relative 'workers/core/traveler_worker'
require_relative 'workers/core/external_tool_worker'