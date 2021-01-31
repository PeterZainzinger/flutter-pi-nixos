{ lib, pkgs, ... }: {
  imports = [ ./20.03/nixos/modules/installer/cd-dvd/sd-image-aarch64.nix ];

  sdImage.compressImage = false;

  users.users.root.password = "root";
  users.extraUsers.root.openssh.authorizedKeys.keys = [''
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDBqMAFlE9NgVyAHBm/QKGpvYoPXk48sP9ZqXi7u0f6MVAJzqcgOXjVJXQYxd5a9rYLca8gdu06G7wmV8MTQQMBdN84zndd4DRQjr/d3+TP9/ay05BjPDWoUijfXP7gW2gXBrU+dGhwH9ihYiK/WyB4wH9pvP94Z2u9QFshLaYGdpMzw6RVum2SEB7vGZOF1scuxquyswdABH13qE56s4tChUf8VYlGokX3bsQcY06fVe+Vx0disfjdokoi/dwLxVFWHKRcW7PRX4R4niyq1Ke5U/v1bG4VmSMYDiDlsbyRRtO52zFIIc/cBzz//ySXibusFVw0TdBtsqp7GCmQBm+TodvInzz6lXxg4kI+m7q43aii5tZGQ1pa+ej7IGYJCnlfNDyOnyweIa95mOuSQFhvW+l46+X5EEDLM+cHynmgJLFGZaZfYDpX2sOyIDqVtNydJ2i5umPqo0U3pXmxrhfjRntQnWDCXPqvBXCJYs3kg2N2sAQ0Fq8cunKHnalm9gDUqFxbT7SA1cxTFyg5h3Aq9N3k9DLfwpiKiUX7XdBXn6eyqe83liN64mp5wBsHvTD59+YVFQh8YuUqfwu2Q/Gvdot5cp+RKbgA9w8V71fl4svM5VMCdwbS4T696TZUHSiBxVVsF+Qlg1OK4MSn+6cbHt/8s2piQKkeJRyEGjcGLQ== peterzainzinger@gmail.com
         ''];
  systemd.services.sshd.wantedBy = lib.mkOverride 40 [ "multi-user.target" ];
  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
  };

  boot.kernelPackages = pkgs.linuxPackages_rpi4;
  #boot.kernelPackages = pkgs.linuxPackages_4_19;

  environment.systemPackages = with pkgs; [ vim ];

}
