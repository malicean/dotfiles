def assert_file [
  source: string,
  span
] {
  if ($source | path type) != file {
    error make {
      msg: 'path is not a file',
      label: {
        text: 'this path',
        span: $span
      }
    }
  }
}

def assert_group [
  name: string
] {
  job group add --parallel 2 $name
}

# Opens a Typst file for editting and opens Zathura as a live-preview
export def main [
  --group (-g): string = "typ", # the pueue group to run the file watcher and zathura
  source: string = "main.typ" # the file to edit
] {
  assert_file $source (metadata $source).span
  assert_group $group

  let render = job spawn raw --group $group $"typst watch ($source)"
  let view = job spawn raw --group $group $"zathura ($source | path change ext pdf)"

  helix $source

  job kill $render.id | ignore
  job kill $view.id | ignore
}
