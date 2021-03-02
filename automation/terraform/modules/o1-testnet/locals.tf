locals {
  block_producer_static_peers = {
    for index, name in keys(data.local_file.libp2p_peers) : name => {
      full_peer = "/dns4/${name}.${var.testnet_name}/tcp/${var.block_producer_starting_host_port + index}/p2p/${trimspace(data.local_file.libp2p_peers[name].content)}",
      port      = var.block_producer_starting_host_port + index
      name      = name
    }
  }

  seed_static_peers = {
    for index, name in keys(data.local_file.libp2p_seed_peers) : name => {
      full_peer = "/dns4/${name}.${var.testnet_name}/tcp/${var.seed_starting_host_port + index}/p2p/${trimspace(data.local_file.libp2p_seed_peers[name].content)}",
      port      = var.seed_starting_host_port + index
      name      = name
    }
  }

  static_peers = merge(local.block_producer_static_peers, local.seed_static_peers)

  whale_block_producer_names = [for i in range(var.whale_count) : "whale-block-producer-${i + 1}"]
  fish_block_producer_names  = [for i in range(var.fish_count) : "fish-block-producer-${i + 1}"]
  seed_names                 = [for i in range(var.seed_count) : "seed-${i + 1}"]
  archive_node_names         = var.archive_node_count == 0 ? [ "" ] : [for i in range(var.archive_node_count) : "archive-${i + 1}:3086"]
}
