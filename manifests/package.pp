define r::package($r_path = '', $repo = 'http://cran.rstudio.com', $dependencies = false, $timeout = 300, $local = false, $creates = undef, $shortname = undef, $environment = []) {

  if $local == true
  {
    $repostring = "NULL"
  }
  else
  {
    $repostring = "'${repo}'"
  }

  if $r_path == '' {
    $binary = '/usr/bin/R'
  }
  else
  {
    $binary = $r_path
  }

  if $shortname == undef {
    $shortnamestring = $name
  }
  else {
    $shortnamestring = $shortname
  }

  $command = $dependencies ? {
    true => "echo \"install.packages('${name}', repos=${repostring}, dependencies = TRUE)\" | R CMD BATCH /dev/stdin /dev/stdout | (grep 'non-zero exit status' || exit 0 && exit 1)",
    default => "echo \"install.packages('${name}', repos=${repostring}, dependencies = FALSE)\" | R CMD BATCH /dev/stdin /dev/stdout | (grep 'non-zero exit status' || exit 0 && exit 1)"
  }

  exec { "install_r_package_${name}":
    environment => $environment,
    command => $command,
    timeout => $timeout,
    path => ["/bin", "/usr/bin", "/usr/sbin", "/sbin"],
    unless => "echo \"'${shortnamestring}' %in% rownames(installed.packages())\" | Rscript --quiet /dev/stdin | grep -v FALSE",
    creates => $creates,
    require => Class['r']
  }

}
