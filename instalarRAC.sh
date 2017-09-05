#!/bin/sh
# Autor: Javier Leonardo Cerón Puentes
# Descripción: Realiza pasos previos a la instalación de base de datos y RAC
# Nota: Modificar el valor de la variable "ThisMachine".
# Nota: Modificar el valor de la variable "SidFromThisNode".
# Nota: Este script no cambia la contraseña del usuario "oracle" 

# Variables para modificar:
export ThisMachine='ol7-121-rac1.localdomain'
export SidFromThisNode='cdbrac1'
export DbUniqueName=''

# Configuración de HostName:
hostname $ThisMachine
hostname > /etc/hostname

# Instalación de paquetes:
yum update -y
yum install -y wget nano net-tools nmap ntp unzip oracle-rdbms-server-12cR1-preinstall.x86_64
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y epel-release-latest-7.noarch.rpm
yum install -y htop

# Configuración de Firewall:
firewall-cmd --zone=public --add-port=1521/tcp --permanent
firewall-cmd --zone=public --add-port=5500/tcp --permanent
firewall-cmd --zone=public --add-port=8000/tcp --permanent
firewall-cmd --zone=public --add-port=8080/tcp --permanent
firewall-cmd --reload

# Configuración de partición para base de datos:
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/sdb
  o # Limpia (en memoria) la tabla de particiones
  w # Aplica la eliminación de las particiones
  n # Nueva partición
  p # Partición primaria
  1 # Partición número 1
    # por defecto - inicia al comienzo del disco
    # por defecto - termina al final del disco
  w # escribe la tabla de particiones
  q # finaliza la creación de particiones
EOF
partprobe /dev/sdb1
mkfs.xfs /dev/sdb1 -f
mkdir /u01
chown oracle:oinstall /u01
echo '/dev/sdb1 /u01 xfs defaults 0 0' | tee -a /etc/fstab
mount /dev/sdb1
mkdir -p  /u01/app/12.1.0.2/grid
mkdir -p /u01/app/oracle/product/12.1.0.2/db_1
chown -R oracle:oinstall /u01

# Configuración de particiones para ASM:
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/sdc
  o # Limpia (en memoria) la tabla de particiones
  w # Aplica la eliminación de las particiones
  n # Nueva partición
  p # Partición primaria
  1 # Partición número 1
    # por defecto - inicia al comienzo del disco
    # por defecto - termina al final del disco
  w # escribe la tabla de particiones
  q # finaliza la creación de particiones
EOF
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/sdd
  o # Limpia (en memoria) la tabla de particiones
  w # Aplica la eliminación de las particiones
  n # Nueva partición
  p # Partición primaria
  1 # Partición número 1
    # por defecto - inicia al comienzo del disco
    # por defecto - termina al final del disco
  w # escribe la tabla de particiones
  q # finaliza la creación de particiones
EOF
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/sde
  o # Limpia (en memoria) la tabla de particiones
  w # Aplica la eliminación de las particiones
  n # Nueva partición
  p # Partición primaria
  1 # Partición número 1
    # por defecto - inicia al comienzo del disco
    # por defecto - termina al final del disco
  w # escribe la tabla de particiones
  q # finaliza la creación de particiones
EOF
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/sdf
  o # Limpia (en memoria) la tabla de particiones
  w # Aplica la eliminación de las particiones
  n # Nueva partición
  p # Partición primaria
  1 # Partición número 1
    # por defecto - inicia al comienzo del disco
    # por defecto - termina al final del disco
  w # escribe la tabla de particiones
  q # finaliza la creación de particiones
EOF
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/sdg
  o # Limpia (en memoria) la tabla de particiones
  w # Aplica la eliminación de las particiones
  n # Nueva partición
  p # Partición primaria
  1 # Partición número 1
    # por defecto - inicia al comienzo del disco
    # por defecto - termina al final del disco
  w # escribe la tabla de particiones
  q # finaliza la creación de particiones
EOF

# Descarga el instalador de la base de datos:
mkdir /instaladores
cd /instaladores
wget https://MyWebSite/archivos/oracle_12c/linuxamd64_12102_database_1of2.zip
wget https://MyWebSite/archivos/oracle_12c/linuxamd64_12102_database_2of2.zip
unzip linuxamd64_12102_database_1of2.zip
unzip linuxamd64_12102_database_2of2.zip
rm -f *.zip

# Descarga el instalador del grid:
mkdir grid
cd grid
wget https://MyWebSite/archivos/oracle_12c/linuxx64_12201_grid_home.zip
unzip linuxx64_12201_grid_home.zip
rm -f *.zip

cd /instaladores
chown oracle:oinstall /instaladores -R

# ###########################################################

yum install -y binutils compat-libcap1 compat-libstdc++-33 compat-libstdc++-33.i686 gcc gcc-c++ glibc glibc.i686 glibc-devel glibc-devel.i686 ksh libgcc libgcc.i686 libstdc++ libstdc++.i686 libstdc++-devel libstdc++-devel.i686 libaio libaio.i686 libaio-devel libaio-devel.i686 libXext libXext.i686 libXtst libXtst.i686 libX11 libX11.i686 libXau libXau.i686 libxcb libxcb.i686 libXi libXi.i686 make sysstat unixODBC unixODBC-devel 

# Crear grupos y usuarios
## groupadd -g 54321 oinstall
## groupadd -g 54322 dba
groupadd -g 54323 oper
groupadd -g 54324 backupdba
groupadd -g 54325 dgdba
groupadd -g 54326 kmdba
groupadd -g 54327 asmdba
groupadd -g 54328 asmoper
groupadd -g 54329 asmadmin
## useradd -u 54321 -g oinstall -G dba,oper oracle

## chmod -R 775 /u01/

# ###########################################################

# Para resolución de nombres en la red NAT (enp0s9):
echo 'nameserver 10.0.2.1' | tee -a /etc/resolv.conf

# Añade resolución de nombres de manera local:
echo '10.0.2.4 ol7-121-scan.localdomain ol7-121-scan' | tee -a /etc/hosts
echo '10.0.2.5 ol7-121-scan.localdomain ol7-121-scan' | tee -a /etc/hosts
echo '10.0.2.6 ol7-121-scan.localdomain ol7-121-scan' | tee -a /etc/hosts

# Cambia el modo actual de SELinux a "permissive" (cambio en memoria):
setenforce permissive
echo "# This file controls the state of SELinux on the system." | tee /etc/selinux/config
echo "# SELINUX= can take one of these three values:" | tee -a /etc/selinux/config
echo "#     enforcing - SELinux security policy is enforced." | tee -a /etc/selinux/config
echo "#     permissive - SELinux prints warnings instead of enforcing." | tee -a /etc/selinux/config
echo "#     disabled - No SELinux policy is loaded." | tee -a /etc/selinux/config
echo "SELINUX=permissive" | tee -a /etc/selinux/config
echo "# SELINUXTYPE= can take one of three two values:" | tee -a /etc/selinux/config
echo "#     targeted - Targeted processes are protected," | tee -a /etc/selinux/config
echo "#     minimum - Modification of targeted policy. Only selected processes are protected." | tee -a /etc/selinux/config
echo "#     mls - Multi Level Security protection." | tee -a /etc/selinux/config
echo "SELINUXTYPE=targeted" | tee -a /etc/selinux/config

# ###########################################################

# Añade configuraciones al archivo "home/oracle/.bash_profile":
echo "# Oracle Settings" | tee -a /home/oracle/.bash_profile
echo "export TMP=/tmp" | tee -a /home/oracle/.bash_profile
echo 'export TMPDIR=$TMP' | tee -a /home/oracle/.bash_profile
echo "export ORACLE_HOSTNAME=$ThisMachine" | tee -a /home/oracle/.bash_profile
echo "export ORACLE_UNQNAME=$DbUniqueName" | tee -a /home/oracle/.bash_profile
echo "export ORACLE_BASE=/u01/app/oracle" | tee -a /home/oracle/.bash_profile
echo "export GRID_HOME=/u01/app/12.1.0.2/grid" | tee -a /home/oracle/.bash_profile
echo "export DB_HOME=$ORACLE_BASE/product/12.1.0.2/db_1" | tee -a /home/oracle/.bash_profile
echo 'export ORACLE_HOME=$DB_HOME' | tee -a /home/oracle/.bash_profile
echo "export ORACLE_SID=$SidFromThisNode" | tee -a /home/oracle/.bash_profile
echo "export ORACLE_TERM=xterm" | tee -a /home/oracle/.bash_profile
echo 'export BASE_PATH=/usr/sbin:$PATH' | tee -a /home/oracle/.bash_profile
echo 'export PATH=$ORACLE_HOME/bin:$BASE_PATH' | tee -a /home/oracle/.bash_profile
echo 'export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib' | tee -a /home/oracle/.bash_profile
echo 'export CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib' | tee -a /home/oracle/.bash_profile
echo 'alias grid_env=". /home/oracle/grid_env"' | tee -a /home/oracle/.bash_profile
echo 'alias db_env=". /home/oracle/db_env"' | tee -a /home/oracle/.bash_profile
chown oracle:oinstall /home/oracle/.bash_profile

# Crea el archivo "/home/oracle/grid_env":
echo 'export ORACLE_SID=+ASM1' | tee -a /home/oracle/grid_env
echo 'export ORACLE_HOME=$GRID_HOME' | tee -a /home/oracle/grid_env
echo 'export PATH=$ORACLE_HOME/bin:$BASE_PATH' | tee -a /home/oracle/grid_env
echo 'export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib' | tee -a /home/oracle/grid_env
echo 'export CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib' | tee -a /home/oracle/grid_env
chown oracle:oinstall /home/oracle/grid_env

# Crea el archivo "/home/oracle/db_env":
echo "export ORACLE_SID=$SidFromThisNode" | tee -a /home/oracle/db_env
echo 'export ORACLE_HOME=$DB_HOME' | tee -a /home/oracle/db_env
echo 'export PATH=$ORACLE_HOME/bin:$BASE_PATH' | tee -a /home/oracle/db_env
echo 'export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib' | tee -a /home/oracle/db_env
echo 'export CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib' | tee -a /home/oracle/db_env
chown oracle:oinstall /home/oracle/db_env

# Vincula discos compartidos (ASM):
echo "options=-g" | tee -a /etc/scsi_id.config
export SDC_ID="$(/usr/lib/udev/scsi_id -g -u -d /dev/sdc)"
export SDD_ID="$(/usr/lib/udev/scsi_id -g -u -d /dev/sdd)"
export SDE_ID="$(/usr/lib/udev/scsi_id -g -u -d /dev/sde)"
export SDF_ID="$(/usr/lib/udev/scsi_id -g -u -d /dev/sdf)"
export SDG_ID="$(/usr/lib/udev/scsi_id -g -u -d /dev/sdg)"

export TEXT_A='KERNEL=="sd?1", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id -g -u -d /dev/$parent", RESULT=="'
export TEXT_B='", '
export TEXT_C='SYMLINK+="oracleasm/asm-disk'
export TEXT_D='", OWNER="oracle", GROUP="dba", MODE="0660"'

echo "$TEXT_A$SDC_ID$TEXT_B$TEXT_C"1"$TEXT_D" | tee -a /etc/udev/rules.d/99-oracle-asmdevices.rules
echo "$TEXT_A$SDD_ID$TEXT_B$TEXT_C"2"$TEXT_D" | tee -a /etc/udev/rules.d/99-oracle-asmdevices.rules
echo "$TEXT_A$SDE_ID$TEXT_B$TEXT_C"3"$TEXT_D" | tee -a /etc/udev/rules.d/99-oracle-asmdevices.rules
echo "$TEXT_A$SDF_ID$TEXT_B$TEXT_C"4"$TEXT_D" | tee -a /etc/udev/rules.d/99-oracle-asmdevices.rules
echo "$TEXT_A$SDG_ID$TEXT_B$TEXT_C"5"$TEXT_D" | tee -a /etc/udev/rules.d/99-oracle-asmdevices.rules

partprobe /dev/sdc1
partprobe /dev/sdd1
partprobe /dev/sde1
partprobe /dev/sdf1
partprobe /dev/sdg1

/sbin/udevadm control --reload-rules

# Reinicia la máquina
shutdown -r now
