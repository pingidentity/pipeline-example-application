mock "tfplan/v2" {
  module {
    source = "../../../imports/deploy-not-true.sentinel"
  }
}

test {
  rules = {
    main            = false
    deploy_true     = false
   }
}
