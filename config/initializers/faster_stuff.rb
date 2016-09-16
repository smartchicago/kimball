# soon we'll have faster_path
if Gem.loaded_specs.has_key? 'faster_path'
  require "faster_path/optional/monkeypatches"
  FasterPath.sledgehammer_everything!
end
