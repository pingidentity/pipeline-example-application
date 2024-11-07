mock "tfplan/v2" {
  module {
    source = "../../../imports/name-incorrect.sentinel"
  }
}

test {
  rules = {
    main            = false
    deployment_name = false
   }
}
