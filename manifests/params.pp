class corosync::params {
  $enable_secauth                      = true
  $authkey_source                      = 'file'
  $authkey                             = '/etc/puppet/ssl/certs/ca.pem'
  $threads                             = $::processorcount
  $port                                = '5405'
  $bind_address                        = $::ipaddress
  $multicast_address                   = 'UNSET'
  $unicast_addresses                   = 'UNSET'
  $force_online                        = false
  $check_standby                       = false
  $debug                               = false
  $rrp_mode                            = 'none'
  $ttl                                 = false
  $token                               = 3000
  $token_retransmits_before_lost_const = 10
  $votequorum_expected_votes           = false

  case $::osfamily {
    'RedHat': {
      $set_votequorum = true
      $compatibility = 'whitetank'
      $manage_pacemaker_service = false
    }

    'Debian': {
      case $::operatingsystem {
        'Ubuntu': {
          if versioncmp($::operatingsystemrelease, '14.04') >= 0 {
            $compatibility = false
            $set_votequorum = true
            $manage_pacemaker_service = true

            file {'/etc/default/cman':
              ensure  => present,
              content => template('corosync/cman.erb'),
            }

          } else {
            $compatibility = 'whitetank'
            $set_votequorum = false
            $manage_pacemaker_service = false
          }
        }
        default : {
          $compatibility = 'whitetank'
          $set_votequorum = false
          $manage_pacemaker_service = false
        }
      }
    }

    default: {
      fail("Unsupported operating system: ${::operatingsystem}")
    }
  }

}
