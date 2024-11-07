mock "tfplan/v2" {
  module {
    source = "./imports/mock-tfplan-v2.sentinel"
  }
}

policy "name-deploy" {
  source = "./policies/name-deploy.sentinel"
}