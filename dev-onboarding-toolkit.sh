#!/bin/bash

# =============================================
# CONFIGURACIÓN INICIAL Y MANEJO PROFESIONAL
# =============================================

# Configuración profesional
set -euo pipefail
trap "echo '❌ Error en línea $LINENO. Script abortado.'; exit 1" ERR
exec > >(tee -a onboarding.log) 2>&1

# Variables globales
REQUIRED_SOFTWARE=("git" "curl" "wget" "build-essential" "python3" "python3-pip" "python3-venv")
UNWANTED_SOFTWARE=("thunderbird*" "libreoffice*" "games-*" "example-content")
OS=""
DISTRO=""
ARCH=""
AUTO_CONFIRM=false
SELECTED_FEATURES=()
REPORT_FILE="onboarding_report_$(date +%Y%m%d_%H%M%S).html"

# =============================================
# FUNCIONES PRINCIPALES
# =============================================

# Detección del sistema
detect_system() {
    echo "🔍 Detectando sistema..."
    sleep 1
    
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        OS=$NAME
        DISTRO=$ID
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si)
        DISTRO=$(lsb_release -sc)
    else
        OS=$(uname -s)
    fi
    
    ARCH=$(uname -m)
    echo "✅ Sistema detectado: $OS ($DISTRO) $ARCH"
}

# Verificación de paquetes instalados
check_installed() {
    if dpkg -l | grep -q "^ii  $1 "; then
        return 0
    else
        return 1
    fi
}

# Instalación de paquetes
install_package() {
    echo "  ⏳ Instalando $1..."
    if sudo apt-get install -y $1 > /dev/null; then
        echo "  ✅ $1 instalado correctamente"
        return 0
    else
        echo "  ❌ Error instalando $1"
        return 1
    fi
}

# Eliminación de paquetes
remove_package() {
    echo "  ⏳ Eliminando $1..."
    if sudo apt-get purge -y $1 > /dev/null; then
        echo "  🗑️ $1 eliminado"
        return 0
    else
        echo "  ⚠️ No se pudo eliminar $1"
        return 1
    fi
}

# =============================================
# MÓDULOS AVANZADOS (ACTIVABLES POR MENÚ)
# =============================================

# 1. Instalación de SDKs específicos
install_sdks() {
    echo "🚀 Instalando SDKs específicos..."
    
    # Node.js (usando nvm para gestión de versiones)
    if ! command -v node &> /dev/null; then
        echo "  ⏳ Instalando Node.js..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
        source ~/.nvm/nvm.sh
        nvm install --lts
        echo "  ✅ Node.js $(node -v) instalado"
    fi
    
    # Docker
    if ! command -v docker &> /dev/null; then
        echo "  ⏳ Instalando Docker..."
        sudo apt-get install -y docker.io docker-compose
        sudo usermod -aG docker $USER
        echo "  ✅ Docker $(docker --version | awk '{print $3}') instalado"
    fi
    
    # Java (OpenJDK 17)
    if ! command -v java &> /dev/null; then
        echo "  ⏳ Instalando Java JDK 17..."
        sudo apt-get install -y openjdk-17-jdk
        echo "  ✅ Java $(java -version 2>&1 | head -n 1 | awk '{print $3}') instalado"
    fi
    
    # PHP 8.2 con extensiones
    if ! command -v php &> /dev/null; then
        echo "  ⏳ Instalando PHP 8.2..."
        sudo add-apt-repository -y ppa:ondrej/php
        sudo apt-get update
        sudo apt-get install -y php8.2 php8.2-cli php8.2-common php8.2-curl php8.2-mbstring php8.2-xml php8.2-zip php8.2-mysql
        echo "  ✅ PHP $(php -v | head -n 1 | awk '{print $2}') instalado"
    fi
    
    # Python virtualenv
    if ! command -v virtualenv &> /dev/null; then
        echo "  ⏳ Instalando virtualenv..."
        pip3 install virtualenv
        echo "  ✅ virtualenv instalado"
    fi
}

# 2. Configuraciones de desarrollo
setup_dev_environment() {
    echo "🛠️ Configurando entorno de desarrollo..."
    
    # Configuración de Git
    if ! git config --global user.name &> /dev/null; then
        read -p "  👤 Introduce tu nombre para Git: " git_name
        git config --global user.name "$git_name"
    fi

    if ! git config --global user.email &> /dev/null; then
        read -p "  ✉️ Introduce tu email para Git: " git_email
        git config --global user.email "$git_email"
    fi
    
    # Aliases útiles
    echo "  ⚙️ Configurando aliases..."
    cat <<EOT >> ~/.bashrc

# ===== ALIASES PARA DESARROLLO =====
alias gs='git status'
alias gp='git pull'
alias gcm='git commit -m'
alias gl='git log --oneline --graph --decorate'
alias docker-purge='docker system prune -a --volumes'
alias update-all='sudo apt update && sudo apt upgrade -y'
alias devlog='tail -f /var/log/apache2/error.log'
EOT
    
    # Instalar Oh-My-Zsh
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "  ⏳ Instalando Oh-My-Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
    
    # Instalar extensiones de VSCode
    if command -v code &> /dev/null; then
        echo "  ⏳ Instalando extensiones VSCode..."
        extensions=(
            "ms-vscode.vscode-typescript-next"
            "xdebug.php-debug"
            "esbenp.prettier-vscode"
            "ms-azuretools.vscode-docker"
            "visualstudioexptteam.vscodeintellicode"
        )
        
        for ext in "${extensions[@]}"; do
            code --install-extension $ext --force > /dev/null
        done
        echo "  ✅ ${#extensions[@]} extensiones instaladas"
    fi
}

# 3. Configuraciones de seguridad
setup_security() {
    echo "🔒 Aplicando configuraciones de seguridad..."
    
    # Firewall básico
    if ! sudo ufw status | grep -q "Status: active"; then
        echo "  ⏳ Configurando firewall (UFW)..."
        sudo ufw default deny incoming
        sudo ufw default allow outgoing
        sudo ufw allow ssh
        sudo ufw allow 80/tcp
        sudo ufw allow 443/tcp
        sudo ufw --force enable
        echo "  ✅ Firewall activado"
    fi
    
    # Configuración SSH
    if grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config; then
        echo "  ⏳ Deshabilitando autenticación por contraseña SSH..."
        sudo sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
        sudo systemctl restart sshd
        echo "  ✅ Solo autenticación por clave permitida"
    fi
    
    # Actualizaciones automáticas de seguridad
    echo "  ⏳ Configurando actualizaciones automáticas..."
    sudo apt-get install -y unattended-upgrades
    sudo dpkg-reconfigure -plow unattended-upgrades
    echo "  ✅ Actualizaciones automáticas activadas"
}

# =============================================
# MENÚS INTERACTIVOS
# =============================================

# Menú principal de características
feature_selection_menu() {
    clear
    echo "========================================"
    echo "  🛠️ MENÚ DE CONFIGURACIÓN DE ONBOARDING  "
    echo "========================================"
    echo
    echo "Selecciona características adicionales:"
    echo
    echo "1) Instalación SDKs específicos (Node.js, Docker, Java, PHP)"
    echo "2) Configuración entorno desarrollo (Git, aliases, extensiones VSCode)"
    echo "3) Configuraciones de seguridad básica (Firewall, SSH)"
    echo "4) TODAS las características anteriores"
    echo "5) Continuar con configuración básica"
    echo
    read -p "Ingresa tu elección (1-5): " choice

    case $choice in
        1) SELECTED_FEATURES=("sdks") ;;
        2) SELECTED_FEATURES=("dev_config") ;;
        3) SELECTED_FEATURES=("security") ;;
        4) SELECTED_FEATURES=("sdks" "dev_config" "security") ;;
        5) SELECTED_FEATURES=() ;;
        *) echo "Opción inválida. Continuando con configuración básica."; SELECTED_FEATURES=() ;;
    esac
}

# Menú de confirmación de acciones
confirmation_menu() {
    local message=$1
    if [ "$AUTO_CONFIRM" = true ]; then
        return 0
    fi
    
    while true; do
        read -p "$message (s/n) " yn
        case $yn in
            [Ss]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) echo "Por favor responde sí (s) o no (n)." ;;
        esac
    done
}

# =============================================
# FUNCIONES DE REPORTING
# =============================================

generate_report_header() {
    cat <<EOT > $REPORT_FILE
<!DOCTYPE html>
<html>
<head>
    <title>Reporte de Onboarding - $(date)</title>
    <style>
        body { font-family: Arial, sans-serif; }
        h1 { color: #2c3e50; }
        .success { color: #27ae60; }
        .warning { color: #f39c12; }
        .error { color: #e74c3c; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        tr:nth-child(even) { background-color: #f2f2f2; }
        th { background-color: #3498db; color: white; }
    </style>
</head>
<body>
    <h1>Reporte de Onboarding para Desarrollador</h1>
    <p><strong>Fecha:</strong> $(date)</p>
    <p><strong>Sistema:</strong> $OS ($DISTRO) $ARCH</p>
    <h2>Resumen de Acciones</h2>
EOT
}

add_report_section() {
    local title=$1
    local content=$2
    
    echo "<h3>$title</h3>" >> $REPORT_FILE
    echo "<table><tr><th>Acción</th><th>Estado</th><th>Detalles</th></tr>" >> $REPORT_FILE
    echo "$content" >> $REPORT_FILE
    echo "</table>" >> $REPORT_FILE
}

generate_report_footer() {
    echo "<h2>Resumen Final</h2>" >> $REPORT_FILE
    echo "<p>Proceso de onboarding completado con éxito.</p>" >> $REPORT_FILE
    echo "<p>Recomendación: Reinicie el sistema para aplicar todos los cambios.</p>" >> $REPORT_FILE
    echo "</body></html>" >> $REPORT_FILE
    
    echo "📊 Reporte generado: file://$(pwd)/$REPORT_FILE"
}

# =============================================
# FLUJO PRINCIPAL
# =============================================

# Manejo de parámetros
while getopts ":y" opt; do
    case $opt in
        y) AUTO_CONFIRM=true ;;
        \?) echo "Opción inválida: -$OPTARG" >&2 ;;
    esac
done

# Inicio del proceso
echo "========================================"
echo "  🚀 INICIO DE ONBOARDING PARA DESARROLLADORES  "
echo "========================================"

# Detección del sistema
detect_system

# Menú de selección de características
feature_selection_menu

# Actualización inicial
if confirmation_menu "¿Actualizar lista de paquetes?"; then
    echo "🔄 Actualizando lista de paquetes..."
    sudo apt-get update > /dev/null
    echo "✅ Lista de paquetes actualizada"
fi

# Verificación de software
echo "🔍 Verificando software instalado..."
MISSING_PKGS=()
FOUND_UNWANTED=()

for pkg in "${REQUIRED_SOFTWARE[@]}"; do
    if check_installed $pkg; then
        echo "✅ $pkg instalado"
    else
        echo "❌ $pkg no encontrado"
        MISSING_PKGS+=("$pkg")
    fi
done

for pkg in "${UNWANTED_SOFTWARE[@]}"; do
    if check_installed $pkg; then
        echo "⚠️ $pkg detectado"
        FOUND_UNWANTED+=("$pkg")
    else
        echo "✅ $pkg no presente"
    fi
done

# Instalación de software faltante
if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
    if confirmation_menu "¿Instalar software faltante (${#MISSING_PKGS[@]} paquetes)?"; then
        for pkg in "${MISSING_PKGS[@]}"; do
            install_package $pkg
        done
    fi
else
    echo "✅ Todo el software requerido ya está instalado"
fi

# Eliminación de software no deseado
if [ ${#FOUND_UNWANTED[@]} -gt 0 ]; then
    if confirmation_menu "¿Eliminar software no deseado (${#FOUND_UNWANTED[@]} paquetes)?"; then
        for pkg in "${FOUND_UNWANTED[@]}"; do
            remove_package $pkg
        done
    fi
else
    echo "✅ No se encontró software no deseado"
fi

# Ejecución de características seleccionadas
for feature in "${SELECTED_FEATURES[@]}"; do
    case $feature in
        "sdks") install_sdks ;;
        "dev_config") setup_dev_environment ;;
        "security") setup_security ;;
    esac
done

# Limpieza final
echo "🧹 Realizando limpieza final..."
sudo apt-get autoremove -y > /dev/null
sudo apt-get clean > /dev/null

# Generación de reporte
generate_report_header

# Mensaje final
echo "========================================"
echo "  🎉 ONBOARDING COMPLETADO CON ÉXITO!  "
echo "========================================"
echo "Tiempo: $SECONDS segundos"
echo "Recomendación: Reinicie el sistema para aplicar todos los cambios"
