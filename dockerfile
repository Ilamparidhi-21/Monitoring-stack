. Create a stable serving directory
sudo mkdir -p /var/www/admin_fe
sudo chown -R ubuntu:ubuntu /var/www/admin_fe
🔧 2. Update Jenkins Pipeline (Add Deploy Stage)
pipeline {
    agent { label 'ubuntu-prod-agent' }

    stages {

        stage('Install Dependencies') {
            steps {
                sh "npm ci"
            }
        }

        stage('Build') {
            steps {
                sh "npm run build"
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                # Create directory if not exists
                mkdir -p /var/www/admin_fe

                # Clean old files
                rm -rf /var/www/admin_fe/*

                # Copy new build
                cp -r dist/* /var/www/admin_fe/
                '''
            }
        }

        stage('Reload Nginx') {
            steps {
                sh "sudo systemctl reload nginx"
            }
        }
    }
}
🔧 3. Fix Nginx

Replace this:

root /home/ubuntu/jenkins-agent/workspace/roho_prod_admin_fe/dist;

With:

root /var/www/admin_fe;
🔁 Reload
sudo nginx -t
sudo systemctl reload nginx
🚀 If You Want to Level Up (Highly Recommended)
🧠 Atomic Deployment (No downtime, no breakage)
Structure:
/var/www/admin_fe/
   ├── releases/
   │     ├── v1/
   │     ├── v2/
   ├── current -> v2
Jenkins Deploy:
VERSION=$(date +%s)

cp -r dist /var/www/admin_fe/releases/$VERSION
ln -sfn /var/www/admin_fe/releases/$VERSION /var/www/admin_fe/current
Nginx:
root /var/www/admin_fe/current;
🛡️ Add Safety Check
if [ ! -f /var/www/admin_fe/current/index.html ]; then
  echo "Deployment failed, index.html missing"
  exit 1
fi
🔥 Bonus: Hidden Issue You Haven’t Noticed

You have:

ssl_certificate /etc/letsencrypt/live/admin.rohowellness.com/fullchain.pem;

for BOTH:

admin.rohowellness.com

core.rohowellness.com

👉 It works only if cert includes both domains
👉 Otherwise can break later

🧠 Final Interview Answer (Polished)

"The issue happened because Nginx was configured to serve static frontend files directly from the Jenkins workspace, which is not a persistent location. Jenkins workspaces can be cleaned or reset due to agent lifecycle events or build processes. When the workspace was cleared, the dist folder was removed, causing Nginx to fail and enter a rewrite loop due to missing index.html."

"We resolved it by redeploying the build, and then permanently fixed it by moving static assets to a stable directory like /var/www and updating Nginx accordingly. We also improved the deployment process to avoid reliance on CI workspaces and added validation and atomic deployments."

🔥 Final Truth

👉 Jenkins didn’t fail
👉 Nginx didn’t fail

👉 Architecture failed
