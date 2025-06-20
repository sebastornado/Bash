----- ESPAÑOL ------

 Explicación del Sistema de Menús
Menú Principal de Funcionalidades:

bash
========================================
  🛠️ MENÚ DE CONFIGURACIÓN DE ONBOARDING  
========================================

Selecciona características adicionales:

1) Instalación SDKs específicos (Node.js, Docker, Java, PHP)
2) Configuración entorno desarrollo (Git, aliases, extensiones VSCode)
3) Configuraciones de seguridad básica (Firewall, SSH)
4) TODAS las características anteriores
5) Continuar con configuración básica

Ingresa tu elección (1-5): 
Selección de Características:

Cada opción activa módulos específicos

El usuario puede combinar funcionalidades

La opción 4 activa todos los módulos avanzados

Menús de Confirmación:

Pregunta antes de cada acción importante

Soporta modo automático con -y

Ejemplo: "¿Instalar software faltante (5 paquetes)?"

🚦 Cómo Usar el Script
Ejecución básica:

bash
chmod +x dev-onboarding-toolkit.sh
./dev-onboarding-toolkit.sh
Modo automático (sin confirmaciones):

bash
./dev-onboarding-toolkit.sh -y
Funcionalidades específicas:

El script mostrará un menú para seleccionar módulos avanzados

📊 Salidas Profesionales
Registro de Ejecución:

Todo se guarda en onboarding.log

Reporte HTML:

Genera un reporte profesional con:

Resumen de acciones

Estado de instalaciones

Configuraciones aplicadas

Recomendaciones post-ejecución

Código de Salida:

0: Éxito

1: Error con detalles en el log

🔄 Flujo Completo
Detección del sistema

Selección de características avanzadas

Análisis de software instalado

Instalación/remoción interactiva

Ejecución de módulos seleccionados

Limpieza y generación de reporte

----- ENGLISH ------

🧩 Menu System Explanation
Main Features Menu:

bash
========================================
  🛠️ ONBOARDING CONFIGURATION MENU  
========================================

Select additional features:

1) Install specific SDKs (Node.js, Docker, Java, PHP)
2) Configure development environment (Git, aliases, VSCode extensions)
3) Basic security configurations (Firewall, SSH)
4) ALL features above
5) Continue with basic configuration

Enter your choice (1-5): 
Feature Selection:

Each option activates specific modules

Users can combine functionalities

Option 4 activates all advanced modules

Confirmation Menus:

Prompts before each important action

Supports automatic mode with -y

Example: "Install missing software (5 packages)?"

🚦 How to Use the Script
Basic execution:

bash
chmod +x dev-onboarding-toolkit.sh
./dev-onboarding-toolkit.sh
Automatic mode (no confirmations):

bash
./dev-onboarding-toolkit.sh -y
Specific features:

The script will display a menu to select advanced modules

📊 Professional Outputs
Execution Log:

Everything saved in onboarding.log

HTML Report:

Generates a professional report with:

Action summary

Installation status

Applied configurations

Post-execution recommendations

Exit Code:

0: Success

1: Error with details in the log

🔄 Complete Workflow
System detection

Advanced feature selection

Installed software analysis

Interactive installation/removal

Execution of selected modules

Cleanup and report generation
