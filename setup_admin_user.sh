# --- Start of Script ---

# 1. Install sudo, the only prerequisite
echo "---> 1/4: Updating packages and installing sudo..."
apt-get update > /dev/null && apt-get install -y sudo > /dev/null

# 2. Create a user named 'testuser' without a password prompt
echo "---> 2/4: Creating user 'testuser'..."
useradd -m -s /bin/bash testuser

# 3. Add the user to the sudo group to grant admin rights
echo "---> 3/4: Granting sudo privileges..."
adduser testuser sudo

# 4. Configure passwordless sudo for this user (the key for convenience)
echo "---> 4/4: Configuring passwordless sudo..."
echo 'testuser ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/testuser

# --- End of Script ---

echo ""
echo "==========================================================="
echo "✅ Setup complete! A user named 'testuser' has been created."
echo "   You can now test your scripts with 'sudo' without a password."
echo "   Switching to the new user now..."
echo "==========================================================="
echo ""

# Automatically switch to the new user's shell
su - testuser  像这个创建非root管理员账户的脚本，我怎么命名这个脚本名称好一点，用英文
