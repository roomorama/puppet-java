# Public: installs java jre-7u40
#
# Examples
#
#    include java
class java {
  include boxen::config

  $jre_version = '7u40'
  $jdk_version = '7u40'
  $jdk_build_number = '43'

  $jdk_dir_name = 'jdk1.7.0_40.jdk'
  $jce_path = "/Library/Java/JavaVirtualMachines/${jdk_dir_name}/Contents/Home/jre/lib/security"

  $jre_dmg_location = "${boxen::config::home}/repo/.tmp/jre.dmg"
  $jdk_dmg_location = "${boxen::config::home}/repo/.tmp/jdk.dmg"
  #jce_zip_location = "${boxen::config::home}/repo/.tmp/jce.zip"

  $wrapper = "${boxen::config::bindir}/java"

  exec { 'download-jre':
    command   => "/usr/bin/curl -o ${jre_dmg_location} -C -k -L -s --header 'Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F;' http://download.oracle.com/otn-pub/java/jdk/${jdk_version}-b${jdk_build_number}/jre-${jre_version}-macosx-x64.dmg",
    creates   => $jre_dmg_location,
  }

  exec { 'download-jdk':
    command   => "/usr/bin/curl -o ${jdk_dmg_location} -C -k -L -s --header 'Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F;' http://download.oracle.com/otn-pub/java/jdk/${jdk_version}-b${jdk_build_number}/jdk-${jdk_version}-macosx-x64.dmg",
    creates   => $jdk_dmg_location,
  }

  package {
    'jre.dmg':
      ensure   => present,
      alias    => 'java-jre',
      provider => pkgdmg,
      source   => $jre_dmg_location,
      require  => Exec['download-jre'];
    'jdk.dmg':
      ensure   => present,
      alias    => 'java',
      provider => pkgdmg,
      source   => $jdk_dmg_location,
      require  => Exec['download-jdk'];
  }

  file { $wrapper:
    source  => 'puppet:///modules/java/java.sh',
    mode    => '0755',
    require => Package['java']
  }

  exec { 'download-jce':
    command => "/usr/bin/curl -o ${jce_zip_location} -C -k -L -s --header 'Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F;' http://download.oracle.com/otn-pub/java/jce/7/UnlimitedJCEPolicyJDK7.zip",
    creates => $jce_zip_location,
    require => Package['java'],
  }

  exec { 'install-jce':
    command => "unzip -f -j -o $jce_zip_location -d $jce_path",
    require => Exec['download-jce'],
    onlyif  => ["test -e $jce_zip_location", "test -d $jce_path"]
  }
}
