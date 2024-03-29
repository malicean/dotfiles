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

  typst compile $source

  let abs = $source | path expand
  let render = job spawn --group $group { watch $abs { typst compile $abs } }
  let view = job spawn raw --group $group $"zathura ($source | path change ext pdf)"

  helix $source

  try {
    job kill $view.id | ignore
  } catch {}
  try {
    job kill $render.id | ignore
  } catch {}
}
