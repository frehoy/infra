resource "hcloud_server" "node1" {
  name        = "node1"
  image       = "ubuntu-20.04"
  server_type = "cx11"
  location    = "hel1" # helsinki
  ssh_keys = [
    hcloud_ssh_key.local_ssh_key.id,
  ]
  labels = {
    "domain" = var.site_domain
  }
  user_data = templatefile("user_data.tftpl", { "pubkey" = file("~/.ssh/id_ed25519.pub") })
}

resource "hcloud_ssh_key" "local_ssh_key" {
  name       = "Terraform local machine SSH key"
  public_key = file("~/.ssh/id_ed25519.pub")
  labels     = {}
}

data "cloudflare_zones" "domain" {
  filter {
    name = var.site_domain
  }
}

resource "cloudflare_record" "site_cname" {
  zone_id = data.cloudflare_zones.domain.zones[0].id
  name    = var.site_domain
  value   = hcloud_server.node1.ipv4_address
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "site_www" {
  zone_id = data.cloudflare_zones.domain.zones[0].id
  name    = "www"
  value   = var.site_domain
  type    = "CNAME"
  ttl     = 1
  proxied = true # Proxy for web traffic
}

resource "cloudflare_record" "site_ssh" {
  zone_id = data.cloudflare_zones.domain.zones[0].id
  name    = "ssh"
  value   = var.site_domain
  type    = "CNAME"
  ttl     = 1
  proxied = false # Don't proxy so we can ssh in
}

output "instance_ip_addr" {
  value = hcloud_server.node1.ipv4_address
}
