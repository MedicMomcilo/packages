# -------------------------------------------------------------------------- #
# Copyright 2002-2012, OpenNebula Project Leads (OpenNebula.org)             #
#                                                                            #
# Licensed under the Apache License, Version 2.0 (the "License"); you may    #
# not use this file except in compliance with the License. You may obtain    #
# a copy of the License at                                                   #
#                                                                            #
# http://www.apache.org/licenses/LICENSE-2.0                                 #
#                                                                            #
# Unless required by applicable law or agreed to in writing, software        #
# distributed under the License is distributed on an "AS IS" BASIS,          #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   #
# See the License for the specific language governing permissions and        #
# limitations under the License.                                             #
#--------------------------------------------------------------------------- #

%define oneadmin_home /var/lib/one
%define oneadmin_uid 9869
%define oneadmin_gid 9869

Name: opennebula
Version: %VERSION%
Summary: Cloud computing solution for Data Center Virtualization
Release: %PKG_VERSION%
License: Apache
Group: System
URL: http://opennebula.org

Source0: opennebula-%{version}.tar.gz
Source1: 50-org.libvirt.unix.manage-opennebula.pkla
Source2: xmlrpc-c.tar.gz
Source3: build_opennebula.sh
Source4: xml_parse_huge.patch

Patch0: proper_path_emulator.diff
Patch1: enable_xen.diff

BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

################################################################################
# Build Requires
################################################################################

BuildRequires: gcc-c++
BuildRequires: libcurl-devel
BuildRequires: libxml2-devel
BuildRequires: xmlrpc-c-devel
BuildRequires: openssl-devel
BuildRequires: mysql-devel
BuildRequires: log4cpp-devel
BuildRequires: sqlite-devel
BuildRequires: openssh
BuildRequires: pkgconfig
BuildRequires: ruby
BuildRequires: scons
BuildRequires: sqlite-devel
BuildRequires: xmlrpc-c
BuildRequires: java-1.7.0-openjdk-devel

################################################################################
# Requires
################################################################################

Requires: openssl
Requires: openssh
Requires: sqlite
Requires: openssh-clients

Requires: %{name}-common = %{version}
Requires: %{name}-ruby = %{version}

################################################################################
# Main Package
################################################################################

Packager: OpenNebula Team <contact@opennebula.org>

%description
OpenNebula.org is an open-source project aimed at building the industry
standard open source cloud computing tool to manage the complexity and
heterogeneity of distributed data center infrastructures.

The OpenNebula.org Project is maintained and driven by the community. The
OpenNebula.org community has thousands of users, contributors, and supporters,
who interact through various online email lists, blogs and innovative projects
to support each other.

OpenNebula is free software released under the Apache License.

This package provides the CLI interface.

################################################################################
# Package opennebula-server
################################################################################

%package server
Summary: Provides the OpenNebula servers
Group: System
Requires: %{name} = %{version}
Requires: openssh-server
Requires: genisoimage
Requires: qemu-img
Requires: xmlrpc-c
Requires: nfs-utils
Requires: wget
Requires: curl
Requires: log4cpp
Obsoletes: %{name}-ozones
#TODO: Requires http://rubygems.org/gems/net-ldap

%description server
This package provides the OpenNebula servers: oned (main daemon) and mm_sched
(scheduler).

################################################################################
# Package common
################################################################################

%package common
Summary: Provides the OpenNebula user
Group: System

%description common
This package creates the oneadmin user and group, with id/gid 9869.

################################################################################
# Package ruby
################################################################################

%package ruby
Summary: Provides the OpenNebula Ruby libraries
Group: System
Requires: ruby
Requires: rubygems
Requires: rubygem-sqlite3-ruby
Requires: rubygem-json
Requires: rubygem-rack
Requires: rubygem-sinatra
Requires: rubygem-thin
Requires: rubygem-uuidtools
Requires: rubygem-nokogiri
Requires: rubygem-sequel
Requires: ruby-mysql

# curb       => For EC2 and OCCI uploads (OPTIONAL: falls back to multipart)

# Missing gems
# aws-sdk    => EC2 hybrid driver (EPEL)
# mysql      => Required to handle MySQL DB upgrades (EPEL)
# treetop    => OneFlow (EPEL)

# amazon-ec2 => used for ec2 server (expose OpenNebula with an EC2 interface)
# net-ldap   => Ldap authentication
# parse-cron => OneFlow

%description ruby
Ruby interface for OpenNebula.

################################################################################
# Package sunstone
################################################################################

%package sunstone
Summary: Browser based UI and public cloud interfaces.
Requires: %{name}-common = %{version}
Requires: %{name}-ruby = %{version}
Requires: python
Requires: numpy

%description sunstone
Browser based UI for administrating a OpenNebula cloud. Also includes
the public cloud interface econe-server (AWS cloud
API).

################################################################################
# Package gate
################################################################################

%package gate
Summary: Transfer information from Virtual Machines to OpenNebula
Requires: %{name}-common = %{version}
Requires: %{name}-ruby = %{version}

%description gate
Transfer information from Virtual Machines to OpenNebula

################################################################################
# Package flow
################################################################################

%package flow
Summary: Manage OpenNebula Services
Requires: %{name}-common = %{version}
Requires: %{name}-ruby = %{version}

%description flow
Manage OpenNebula Services

################################################################################
# Package java
################################################################################

%package java
Summary: Java interface to OpenNebula Cloud API
Group:   System

%description java
Java interface to OpenNebula Cloud API.

################################################################################
# Package node-kvm
################################################################################

%package node-kvm
Summary: Configures an OpenNebula node providing kvm
Group: System
Conflicts: %{name}-node-xen
Requires: ruby
Requires: openssh-server
Requires: openssh-clients
Requires: libvirt
Requires: qemu-kvm
Requires: qemu-img
Requires: nfs-utils
Requires: bridge-utils
Requires: ipset
Requires: pciutils
Requires: %{name}-common = %{version}

%description node-kvm
Configures an OpenNebula node providing kvm.

################################################################################
# Package node-xen
################################################################################

# %package node-xen
# Summary: Configures an OpenNebula node providing xen
# Group: System
# Conflicts: %{name}-node-kvm
# Requires: centos-release-xen
# Requires: ruby
# Requires: openssh-server
# Requires: openssh-clients
# Requires: xen
# Requires: nfs-utils
# Requires: bridge-utils
# Requires: %{name}-common = %{version}
#
# %description node-xen
# Configures an OpenNebula node providing xen.

################################################################################
# Build and install
################################################################################

%prep
%setup -q

%patch0 -p1
%patch1 -p1

%build
# Uncompress xmlrpc-c and copy build_opennebula.sh
(
    cd ..
    tar xzvf %{SOURCE2}
    cp %{SOURCE3} %{SOURCE4} .
)

# Compile OpenNebula
# scons -j2 mysql=yes syslog=yes new_xmlrpc=yes
../build_opennebula.sh syslog=yes
cd src/oca/java
./build.sh -d

%install
export DESTDIR=%{buildroot}
./install.sh
%{__mkdir} -p %{buildroot}%{_initddir}

# Init scripts
install -p -D -m 755 share/pkgs/CentOS/opennebula %{buildroot}%{_initddir}/opennebula
install -p -D -m 755 share/pkgs/CentOS/opennebula-sunstone %{buildroot}%{_initddir}/opennebula-sunstone

install -p -D -m 755 share/pkgs/CentOS/opennebula-gate  %{buildroot}%{_initddir}/opennebula-gate
install -p -D -m 755 share/pkgs/CentOS/opennebula-econe %{buildroot}%{_initddir}/opennebula-econe
install -p -D -m 755 share/pkgs/CentOS/opennebula-flow  %{buildroot}%{_initddir}/opennebula-flow
install -p -D -m 755 share/pkgs/CentOS/opennebula-novnc %{buildroot}%{_initddir}/opennebula-novnc

install -p -D -m 644 %{SOURCE1} \
        %{buildroot}%{_sysconfdir}/polkit-1/localauthority/50-local.d/50-org.libvirt.unix.manage-opennebula.pkla

# sudoers
%{__mkdir} -p %{buildroot}%{_sysconfdir}/sudoers.d
install -p -D -m 440 share/pkgs/CentOS/opennebula.sudoers %{buildroot}%{_sysconfdir}/sudoers.d/opennebula

# logrotate
%{__mkdir} -p %{buildroot}%{_sysconfdir}/logrotate.d
install -p -D -m 440 share/pkgs/logrotate/opennebula %{buildroot}%{_sysconfdir}/logrotate.d/opennebula

# Java
install -p -D -m 644 src/oca/java/jar/org.opennebula.client.jar %{buildroot}%{_javadir}/org.opennebula.client.jar

%clean
%{__rm} -rf %{buildroot}

################################################################################
# common - scripts
################################################################################

%pre common
getent group oneadmin >/dev/null || groupadd -r -g %{oneadmin_gid} oneadmin
if getent passwd oneadmin >/dev/null; then
    /usr/sbin/usermod -a -G oneadmin oneadmin > /dev/null
else
    /usr/sbin/useradd -r -m -d %{oneadmin_home} \
    -u %{oneadmin_uid} -g %{oneadmin_gid} \
    -s /bin/bash oneadmin 2> /dev/null
fi

if ! getent group disk | grep '\boneadmin\b' &>/dev/null ; then
    usermod -a -G disk oneadmin
fi

################################################################################
# server - scripts
################################################################################

%pre server
# Upgrade - Stop the service
if [ $1 = 2 ]; then
    /sbin/service opennebula stop >/dev/null || :
fi

%post server
if [ $1 = 1 ]; then
    /sbin/chkconfig --add opennebula >/dev/null
    if [ ! -e %{oneadmin_home}/.one/one_auth ]; then
        PASSWORD=$(echo $RANDOM$(date '+%s')|md5sum|cut -d' ' -f1)
        mkdir -p %{oneadmin_home}/.one
        echo oneadmin:$PASSWORD > %{oneadmin_home}/.one/one_auth
        /bin/chown -R oneadmin:oneadmin %{oneadmin_home}/.one
    fi

    if [ ! -d "%{oneadmin_home}/.ssh" ]; then
        su oneadmin -c "ssh-keygen -N '' -t dsa -f %{oneadmin_home}/.ssh/id_dsa"
        cp -p %{oneadmin_home}/.ssh/id_dsa.pub %{oneadmin_home}/.ssh/authorized_keys
        /bin/chmod 600 %{oneadmin_home}/.ssh/authorized_keys
    fi
fi

%preun server
if [ $1 = 0 ]; then
    /sbin/service opennebula stop >/dev/null || :
    /sbin/chkconfig --del opennebula >/dev/null
fi

################################################################################
# node-kvm - scripts
################################################################################

%post node-kvm
if [ $1 = 1 ]; then
    # Install
    if [ -e /etc/libvirt/qemu.conf ]; then
        cp /etc/libvirt/qemu.conf /etc/libvirt/qemu.conf.orig

        echo 'user  = "oneadmin"'    >  /etc/libvirt/qemu.conf
        echo 'group = "oneadmin"'    >> /etc/libvirt/qemu.conf
        echo 'dynamic_ownership = 0' >> /etc/libvirt/qemu.conf
    fi
elif [ $1 = 2 ]; then
    # Upgrade
    PID=$(cat /tmp/one-collectd-client.pid 2> /dev/null)
    [ -n "$PID" ] && kill $PID 2> /dev/null || :
fi

################################################################################
# node-xen - scripts
################################################################################

# %post node-xen
# if [ $1 = 1 ]; then
#     /usr/bin/grub-bootxen.sh
# fi

################################################################################
# sunstone - scripts
################################################################################

%pre sunstone
if [ $1 = 2 ]; then
    /sbin/service opennebula-sunstone stop >/dev/null || :
    /sbin/service opennebula-novnc stop >/dev/null || :
fi

%post sunstone
if [ $1 = 1 ]; then
    /sbin/chkconfig --add opennebula-sunstone >/dev/null
fi

%preun sunstone
if [ $1 = 0 ]; then
    /sbin/service opennebula-sunstone stop >/dev/null  || :
    /sbin/chkconfig --del opennebula-sunstone >/dev/null
    /sbin/service opennebula-novnc stop >/dev/null  || :
    /sbin/chkconfig --del opennebula-novnc >/dev/null
fi

################################################################################
# ruby - scripts
################################################################################

%post ruby
cat <<EOF
Please remember to execute /usr/share/one/install_gems to install all the
required gems.
EOF

################################################################################
# common - files
################################################################################

%files common
%config %{_sysconfdir}/sudoers.d/opennebula

/usr/share/docs/one/*

################################################################################
# node-kvm - files
################################################################################

%files node-kvm
%config %{_sysconfdir}/polkit-1/localauthority/50-local.d/50-org.libvirt.unix.manage-opennebula.pkla

################################################################################
# node-xen - files
################################################################################

# %files node-xen

################################################################################
# java - files
################################################################################

%files java
%defattr(-,root,root)
%{_javadir}/org.opennebula.client.jar

################################################################################
# ruby - files
################################################################################

%files ruby
%defattr(0640, root, oneadmin, 0750)
%dir %{_sysconfdir}/one
%config %{_sysconfdir}/one/auth/server_x509_auth.conf
%config %{_sysconfdir}/one/auth/ldap_auth.conf
%config %{_sysconfdir}/one/auth/x509_auth.conf

%defattr(-, root, root, 0755)
/usr/lib/one/ruby/opennebula.rb
/usr/lib/one/ruby/opennebula/*
/usr/lib/one/ruby/vendors/rbvmomi/*
/usr/lib/one/ruby/vcenter_driver.rb

/usr/lib/one/ruby/OpenNebula.rb

/usr/lib/one/ruby/cloud/CloudClient.rb
/usr/lib/one/ruby/cloud/CloudAuth.rb
/usr/lib/one/ruby/cloud/CloudServer.rb
/usr/lib/one/ruby/cloud/CloudAuth/*

%{_datadir}/one/install_gems

################################################################################
# sunstone - files
################################################################################

%files sunstone
%defattr(0640, root, oneadmin, 0750)
%dir %{_sysconfdir}/one
%config %{_sysconfdir}/one/sunstone-server.conf
%config %{_sysconfdir}/one/sunstone-logos.yaml
%config %{_sysconfdir}/one/ec2query_templates/*
%config %{_sysconfdir}/one/econe.conf
%config %{_sysconfdir}/one/sunstone-views.yaml
%config %{_sysconfdir}/one/sunstone-views/*
%config %{_sysconfdir}/one/ec2_driver.conf
%config %{_sysconfdir}/one/ec2_driver.default

%defattr(-, root, root, 0755)
/usr/lib/one/sunstone/*
/usr/lib/one/ruby/OpenNebulaVNC.rb
/usr/lib/one/ruby/cloud/econe/*

%{_bindir}/sunstone-server
%{_bindir}/novnc-server

%{_bindir}/econe-server

%{_bindir}/econe-allocate-address
%{_bindir}/econe-associate-address
%{_bindir}/econe-attach-volume
%{_bindir}/econe-create-keypair
%{_bindir}/econe-create-volume
%{_bindir}/econe-delete-keypair
%{_bindir}/econe-delete-volume
%{_bindir}/econe-describe-addresses
%{_bindir}/econe-describe-images
%{_bindir}/econe-describe-instances
%{_bindir}/econe-describe-keypairs
%{_bindir}/econe-describe-volumes
%{_bindir}/econe-detach-volume
%{_bindir}/econe-disassociate-address
%{_bindir}/econe-reboot-instances
%{_bindir}/econe-register
%{_bindir}/econe-release-address
%{_bindir}/econe-run-instances
%{_bindir}/econe-start-instances
%{_bindir}/econe-stop-instances
%{_bindir}/econe-terminate-instances
%{_bindir}/econe-upload

%{_initddir}/opennebula-sunstone
%{_initddir}/opennebula-econe
%{_initddir}/opennebula-novnc

%{_datadir}/one/websockify/*

%defattr(-, oneadmin, oneadmin, 0750)

%dir %{_localstatedir}/lock/one
%dir %{_localstatedir}/log/one
%dir %{_localstatedir}/run/one

################################################################################
# gate - files
################################################################################

%files gate

%defattr(0640, root, oneadmin, 0750)
%dir %{_sysconfdir}/one
%config %{_sysconfdir}/one/onegate-server.conf

%defattr(-, root, root, 0755)
/usr/lib/one/onegate/*

%{_bindir}/onegate-server

%{_initddir}/opennebula-gate

%defattr(-, oneadmin, oneadmin, 0750)

%dir %{_localstatedir}/lock/one
%dir %{_localstatedir}/log/one
%dir %{_localstatedir}/run/one

################################################################################
# flow - files
################################################################################

%files flow

%defattr(0640, root, oneadmin, 0750)
%dir %{_sysconfdir}/one
%config %{_sysconfdir}/one/oneflow-server.conf

%defattr(-, root, root, 0755)
/usr/lib/one/oneflow/*

%{_bindir}/oneflow-server

%{_initddir}/opennebula-flow

%defattr(-, oneadmin, oneadmin, 0750)

%dir %{_localstatedir}/lock/one
%dir %{_localstatedir}/log/one
%dir %{_localstatedir}/run/one

################################################################################
# server - files
################################################################################

%files server
%defattr(0640, root, oneadmin, 0750)
%dir %{_sysconfdir}/one
%config %{_sysconfdir}/one/defaultrc
%config %{_sysconfdir}/one/hm/*
%config %{_sysconfdir}/one/oned.conf
%config %{_sysconfdir}/one/sched.conf
%config %{_sysconfdir}/one/vmm_exec/*
%config %{_sysconfdir}/one/az_driver.conf
%config %{_sysconfdir}/one/az_driver.default
%config %{_sysconfdir}/one/sl_driver.conf
%config %{_sysconfdir}/one/sl_driver.default
%config %{_sysconfdir}/logrotate.d/opennebula

%defattr(-, root, root, 0755)
%{_initddir}/opennebula

%{_bindir}/mm_sched

%{_bindir}/one
%{_bindir}/oned
%{_bindir}/onedb
%{_bindir}/tty_expect

%{_datadir}/one/examples/*

/usr/lib/one/mads/*
/usr/lib/one/ruby/ActionManager.rb
/usr/lib/one/ruby/az_driver.rb
/usr/lib/one/ruby/CommandManager.rb
/usr/lib/one/ruby/DriverExecHelper.rb
/usr/lib/one/ruby/ec2_driver.rb
/usr/lib/one/ruby/onedb/*
/usr/lib/one/ruby/one_vnm.rb
/usr/lib/one/ruby/OpenNebulaDriver.rb
/usr/lib/one/ruby/scripts_common.rb
/usr/lib/one/ruby/sl_driver.rb
/usr/lib/one/ruby/ssh_stream.rb
/usr/lib/one/ruby/VirtualMachineDriver.rb
/usr/lib/one/sh/*

%doc %{_mandir}/man1/
%doc LICENSE NOTICE

%defattr(-, oneadmin, oneadmin, 0750)

%dir %{_sharedstatedir}/one
%dir %{_sharedstatedir}/one/datastores
%dir %{_sharedstatedir}/one/remotes

%dir %{_localstatedir}/lock/one
%dir %{_localstatedir}/log/one
%dir %{_localstatedir}/run/one

%{_sharedstatedir}/one/datastores/*
%{_sharedstatedir}/one/vms
%config %{_sharedstatedir}/one/remotes/*

################################################################################
# main package - files
################################################################################

%files
%defattr(0640, root, oneadmin, 0750)
%dir %{_sysconfdir}/one
%defattr(-, root, root, 0755)
%config %{_sysconfdir}/one/cli/*

%{_bindir}/oneacl
%{_bindir}/onecluster
%{_bindir}/onedatastore
%{_bindir}/onegroup
%{_bindir}/onehost
%{_bindir}/oneimage
%{_bindir}/onemarket
%{_bindir}/onemarketapp
%{_bindir}/onetemplate
%{_bindir}/oneuser
%{_bindir}/onevm
%{_bindir}/onevnet
%{_bindir}/oneacct
%{_bindir}/onezone
%{_bindir}/onevcenter
%{_bindir}/onesecgroup
%{_bindir}/oneshowback
%{_bindir}/onevdc
%{_bindir}/onevrouter

%{_bindir}/oneflow
%{_bindir}/oneflow-template

/usr/lib/one/ruby/cli/*


################################################################################
# Changelog
################################################################################

%changelog
* Mon May 05 2014 Jaime Melis <jmelis@opennebula.org> - 4.6.0-0.1
- New upstream release
- Apply a few fixes to the package scripts, so they don't fail on upgrade.

* Mon Feb 24 2014 Jaime Melis <jmelis@opennebula.org> - 4.4.1-0.1
- New upstream release
- Disable the node-xen package
- Remove ozones package

* Fri Jan 31 2014 Jaime Melis <jmelis@opennebula.org> - 4.4.0-0.3
- Enable the node-xen package

* Wed Dec 04 2013 Jaime Melis <jmelis@opennebula.org> - 4.4.0-0.2
- Refres patches
- Add init scripts

* Wed Oct 09 2013 Jaime Melis <jmelis@opennebula.org> - 4.4.0-0.1
- New upstream release
- Remove Ganglia

* Thu Sep 12 2013 Jaime Melis <jmelis@opennebula.org> - 4.2.0-0.6
- Add opennebula.sudoers file
- Refresh enable_xen patch again
- Disable xen for the time being

* Wed Sep 11 2013 Jaime Melis <jmelis@opennebula.org> - 4.2.0-0.4
- Fix xen dependencies
- Refresh enable_xen patch

* Tue Sep 10 2013 Jaime Melis <jmelis@opennebula.org> - 4.2.0-0.3
- Add 99-execute-scripts to the context package

* Mon Sep 09 2013 Jaime Melis <jmelis@opennebula.org> - 4.2.0-0.2
- scons uses the old_xmlrpc dynamically linked libs

* Fri Jul 26 2013 Jaime Melis <jmelis@opennebula.org> - 4.2.0-0.1
- New upstream version 4.2.0
- New packages: opennebula-gate and opennebula-flow
- Fix dependencies

* Fri Jul 12 2013 Jaime Melis <jmelis@opennebula.org> - 4.1.0-0.2
- Add oneflow
- Fix deps

* Mon Jul 08 2013 Jaime Melis <jmelis@opennebula.org> - 4.1.0-0.1
- New package for onegate
- Include rbvmomi

* Fri May 17 2013 Jaime Melis <jmelis@opennebula.org> - 4.0.1-0.1
- new upstream release OpenNebula 4.0.1
- context files are available in the source tree
- novnc is included in the distribution

* Wed Apr 24 2013 Jaime Melis <jmelis@opennebula.org> - 3.9.90-0.2
- new upstream release OpenNebula 4.0 RC2
- fix oZones permission issues
- new Sunstone conf files
- new context files

* Sat Apr 06 2013 Jaime Melis <jmelis@opennebula.org> - 3.9.80-0.4
- Update upstream tarball
- fix novnc patch

* Fri Apr 05 2013 Jaime Melis <jmelis@opennebula.org> - 3.9.80-0.3
- remove install_novnc.sh from the packages

* Wed Apr 03 2013 Jaime Melis <jmelis@opennebula.org> - 3.9.80-0.2
- package novnc
- enable xen4 by default
- add node-xen package

* Wed Mar 13 2013 Jaime Melis <jmelis@opennebula.org> - 3.9.80-0.1
- Prepare file schema for a new upstream release
- Create a new oZones package
- Move OCCI and econe to the sunstone package

* Mon Dec 03 2012 Jaime Melis <jmelis@opennebula.org> - 3.8.1-2.6
- Fix bug in the polkit installation
- Fix another bug in the polkit installation
- Usermod expects the groupname for the -G parameter

* Mon Nov 19 2012 Jaime Melis <jmelis@opennebula.org> - 3.8.1-2.3
- Fix some node-kvm issues

* Wed Oct 31 2012 Jaime Melis <jmelis@opennebula.org> - 3.8.1-2.2
- Improve context scripts for DNS and SSH keys

* Fri Oct 26 2012 Jaime Melis <jmelis@opennebula.org> - 3.8.1-2.1
- The Sunstone package doesn't have all the required files
- Fix all the init.d files (upstream #1289)
- Additional required files by Sunstone
- New upstream release: 3.8.1
- Properly remove the fix-inits patch
- Add a DNS and SSH_PUBLIC_KEY scripts for the context package
- Fix bug where the 00-network was being overwritten

* Thu Oct 25 2012 Jaime Melis <jmelis@opennebula.org> - 3.8.0-3.2
- Proper permissions for the 00-network script in the context package
- Create the /var/{run,lock,log}/one for the sunstone package
- Fix the sunstone-server script
- Proper permissions for /etc/one in all the packages

* Wed Oct 24 2012 Jaime Melis <jmelis@opennebula.org> - 3.8.0-3
- Update copyright
- Add section comments
- New package layout
- Add the context package

* Tue Oct 23 2012 Karanbir Singh <kbsingh@karan.org> - 3.8.0-1
- Rebase to 3.8.0 now that its released

* Mon Oct 22 2012 Karanbir Singh <kbsingh@karan.org> - 3.7.85-1.0.1
- Bump Release
- Rebuild cleanly

* Tue Oct 16 2012 Jaime Melis <jmelis@opennebula.org> - 3.7.85-1.0
- Prepare the package for the next upstream tar that already provides sunstone
  and occi daemons.

* Fri Oct 5 2012 Jaime Melis <jmelis@opennebula.org> - 3.7.80-1.8
- New package: opennebula-node-kvm
- Update missing requirements (ssh, nfs)
- Update README with new shared storage workflow
- Fix uid/gid for oneadmin
- Rename init.d scripts to: opennebula and opennebula-sunstone
- New patch for faster monitorization time
- New patch for proper qemu-kvm path in nodes
- Add %preun and %post actions for the sunstone package

* Thu Oct 4 2012 Karanbir Singh <kbsingh@karan.org> - 3.7.80-1.7
- Roll back to beta build ID

* Wed Oct 3 2012 Karanbir Singh <kbsingh@karan.org> - 3.8.0-1.3
- Import from upstream
- Move spec name to match package
- Move the oneadmin password gen to %post so everyone gets
  a unique value
- Add some more macros into placeholders
- trim down the pre script and move to %files
- ensure we have the same path everywhere
- add wget as a dependency
- make permissions more secure
