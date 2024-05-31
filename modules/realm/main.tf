
# Realm
resource "keycloak_realm" "realm" {
  realm = var.realm_name
  enabled = true
  display_name = "https://esg-frontend-service.${var.default_domain}"
  display_name_html = "https://esg-frontend-service.${var.default_domain}"

  reset_password_allowed = true
  login_with_email_allowed = true
  registration_email_as_username = true

  login_theme = var.login_theme
  email_theme = "sw-custom-theme"
  default_signature_algorithm = "RS256"
  sso_session_idle_timeout = "14400s"

  smtp_server {
    host = var.smtp_host
    port = var.smtp_port
    from = var.smtp_from
    from_display_name = var.smtp_from
    reply_to = var.smtp_from
    starttls = true

    auth {
      username = var.smtp_username
      password = var.smtp_password
    }
  }
}

# Events

resource "keycloak_realm_events" "realm_events" {
  realm_id = keycloak_realm.realm.id

  events_enabled    = true
  events_expiration = 15552000 # 180 days expiration time

  admin_events_enabled         = true
  admin_events_details_enabled = true

}

resource "keycloak_realm_events" "realm_events_master" {
  realm_id = "master"

  events_enabled    = true
  events_expiration = 15552000 # 180 days expiration time

  admin_events_enabled         = true
  admin_events_details_enabled = true

}




# Roles
data "keycloak_openid_client" "realm_management" {
  realm_id  = keycloak_realm.realm.id
  client_id = "realm-management"
}

data "keycloak_role" "view-users_role" {
  realm_id  = keycloak_realm.realm.id
  client_id = data.keycloak_openid_client.realm_management.id
  name      = "view-users"
}

data "keycloak_role" "manage-users_role" {
  realm_id  = keycloak_realm.realm.id
  client_id = data.keycloak_openid_client.realm_management.id
  name      = "manage-users"
}

data "keycloak_openid_client" "account" {
  realm_id  = keycloak_realm.realm.id
  client_id = "account"
}

data "keycloak_role" "view_profile_role" {
  realm_id  = keycloak_realm.realm.id
  client_id = data.keycloak_openid_client.account.id
  name      = "view-profile"
}

data "keycloak_role" "manage_account_role" {
  realm_id  = keycloak_realm.realm.id
  client_id = data.keycloak_openid_client.account.id
  name      = "manage-account"
}

resource "keycloak_role" "admin_role" {
  realm_id    = keycloak_realm.realm.id
  name        = "admin"
  composite_roles = [ data.keycloak_role.view-users_role.id, data.keycloak_role.manage-users_role.id ]
  depends_on = [ keycloak_realm.realm]
}

resource "keycloak_role" "carbon_role" {
  realm_id    = keycloak_realm.realm.id
  name        = "carbon"
  depends_on = [ keycloak_realm.realm ]
}

resource "keycloak_role" "organizer_role" {
  realm_id    = keycloak_realm.realm.id
  name        = "organizer"
  depends_on = [ keycloak_realm.realm ]
}

resource "keycloak_role" "reporting_role" {
  realm_id    = keycloak_realm.realm.id
  name        = "reporting"
  depends_on = [ keycloak_realm.realm ]
}

resource "keycloak_role" "respondent_role" {
  realm_id    = keycloak_realm.realm.id
  name        = "respondent"
  depends_on = [ keycloak_realm.realm ]
}


# Groups
resource "keycloak_group" "default_group" {
  realm_id = keycloak_realm.realm.id
  name     = "default"
}

resource "keycloak_default_groups" "default" {
  realm_id  = keycloak_realm.realm.id
  group_ids = [
    keycloak_group.default_group.id
  ]
}

resource "keycloak_group_roles" "default_group_roles" {
  realm_id = keycloak_realm.realm.id
  group_id = keycloak_group.default_group.id

  role_ids = [
    data.keycloak_role.view-users_role.id,
    data.keycloak_role.view_profile_role.id,
    data.keycloak_role.manage_account_role.id
  ]
}

resource "keycloak_group" "admin_group" {
  realm_id = keycloak_realm.realm.id
  name     = "admin"
}

resource "keycloak_group_roles" "admin_group_roles" {
  realm_id = keycloak_realm.realm.id
  group_id = keycloak_group.admin_group.id

  role_ids = [
    keycloak_role.admin_role.id,
    keycloak_role.carbon_role.id,
    keycloak_role.organizer_role.id,
    keycloak_role.reporting_role.id,
    keycloak_role.respondent_role.id

  ]
}

resource "keycloak_group" "carbon_group" {
  realm_id = keycloak_realm.realm.id
  name     = "carbon"
}

resource "keycloak_group_roles" "carbon_group_roles" {
  realm_id = keycloak_realm.realm.id
  group_id = keycloak_group.carbon_group.id

  role_ids = [
    keycloak_role.carbon_role.id
  ]
}

resource "keycloak_group" "esg_organizer_group" {
  realm_id = keycloak_realm.realm.id
  name     = "esg_organizer"
}

resource "keycloak_group_roles" "esg_organizer_group_roles" {
  realm_id = keycloak_realm.realm.id
  group_id = keycloak_group.esg_organizer_group.id

  role_ids = [
    keycloak_role.organizer_role.id
  ]
}

resource "keycloak_group" "reporting_group" {
  realm_id = keycloak_realm.realm.id
  name     = "reporting"
}

resource "keycloak_group_roles" "reporting_group_roles" {
  realm_id = keycloak_realm.realm.id
  group_id = keycloak_group.reporting_group.id

  role_ids = [
    keycloak_role.reporting_role.id
  ]
}

resource "keycloak_group" "esg_respondent_group" {
  realm_id = keycloak_realm.realm.id
  name     = "esg_respondent"
}

resource "keycloak_group_roles" "esg_respondent_group_roles" {
  realm_id = keycloak_realm.realm.id
  group_id = keycloak_group.esg_respondent_group.id

  role_ids = [
    keycloak_role.respondent_role.id
  ]
}


# Client Scopes
resource "keycloak_openid_client_scope" "client_scopes" {
  realm_id               = keycloak_realm.realm.id
  name                   = "client-scopes"
  include_in_token_scope = true
  consent_screen_text = true
}


# Authentication Flow
resource "keycloak_authentication_flow" "oidc_flow" {
  realm_id = keycloak_realm.realm.id
  alias    = "OIDC Flow"
  description = "OIDC Flow"
  provider_id = "basic-flow"
}

resource "keycloak_authentication_execution" "execution_one" {
  realm_id          = "${keycloak_realm.realm.id}"
  parent_flow_alias = "${keycloak_authentication_flow.oidc_flow.alias}"
  authenticator     = "idp-detect-existing-broker-user"
  requirement       = "REQUIRED"
}

resource "keycloak_authentication_execution" "execution_two" {
  realm_id          = "${keycloak_realm.realm.id}"
  parent_flow_alias = "${keycloak_authentication_flow.oidc_flow.alias}"
  authenticator     = "idp-review-profile"
  requirement       = "REQUIRED"

  depends_on = [ keycloak_authentication_execution.execution_one ]
}

resource "keycloak_authentication_execution" "execution_three" {
  realm_id          = "${keycloak_realm.realm.id}"
  parent_flow_alias = "${keycloak_authentication_flow.oidc_flow.alias}"
  authenticator     = "idp-auto-link"
  requirement       = "REQUIRED"

  depends_on = [ keycloak_authentication_execution.execution_two ]
}

resource "keycloak_authentication_execution" "execution_four" {
  realm_id          = "${keycloak_realm.realm.id}"
  parent_flow_alias = "${keycloak_authentication_flow.oidc_flow.alias}"
  authenticator     = "allow-access-authenticator"
  requirement       = "REQUIRED"

  depends_on = [ keycloak_authentication_execution.execution_three ]
}

# Initial admin user
resource "keycloak_user" "user_with_initial_password" {
  realm_id   = keycloak_realm.realm.id
  username   = var.app_admin_email
  enabled    = true

  email      = var.app_admin_email
  first_name = var.app_admin_first_name
  last_name  = var.app_admin_last_name

  initial_password {
    value     = var.app_admin_initial_password
    temporary = true
  }
}

resource "keycloak_user" "reporting_user" {
  realm_id   = keycloak_realm.realm.id
  username   = "reporting@solitwork.com"
  enabled    = true

  email      = "reporting@solitwork.com"
  first_name = "reporting"
  last_name  = "reporting"

  initial_password {
    value     = var.reportingpassword
    temporary = false
  }
}

resource "keycloak_user_groups" "user_groups" {
  realm_id = keycloak_realm.realm.id
  user_id = keycloak_user.user_with_initial_password.id

  group_ids  = [
    keycloak_group.admin_group.id,
  ]
}

resource "keycloak_user_groups" "user_groups_reporting" {
  realm_id = keycloak_realm.realm.id
  user_id = keycloak_user.reporting_user.id

  group_ids  = [
    keycloak_group.admin_group.id,
  ]
}

# Clients
# ------- VAT -------
resource "keycloak_openid_client" "vat" {
  realm_id            = keycloak_realm.realm.id
  client_id           = "afc-vat"

  name                = "afc-vat"
  description         = "afc-vat"
  enabled             = true

  access_type         = "PUBLIC"
  web_origins = [ "+" ]
  valid_redirect_uris = [
    "${var.vat_frontend_url}/*",
    "https://${var.realm_name}.afcdemo.com/*",
    "http://localhost*",
    "http://localhost/*",
    "http://localhost:4200*",
    "http://localhost:4200/*"
  ]
  standard_flow_enabled = true
  implicit_flow_enabled = true
  oauth2_device_authorization_grant_enabled = true
  direct_access_grants_enabled = true

  frontchannel_logout_enabled = true

  depends_on = [ keycloak_realm.realm ]
}

resource "keycloak_openid_client_default_scopes" "vat_default_scopes_mapper" {
  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.vat.id

  default_scopes = [
    "acr",
    keycloak_openid_client_scope.client_scopes.name,
    "email",
    "profile",
    "roles",
    "web-origins"
  ]
  depends_on = [ keycloak_realm.realm, keycloak_openid_client.vat, keycloak_openid_client_scope.client_scopes ]
}

resource "keycloak_openid_audience_protocol_mapper" "vat_audience_mapper" {
  realm_id  = keycloak_realm.realm.id
  client_scope_id = keycloak_openid_client_scope.client_scopes.id
  name      = "vat-client-mapper"

  included_client_audience = keycloak_openid_client.vat.client_id
  # included_custom_audience = "afc-vat"
  add_to_access_token = true
  add_to_id_token = false
}

# ------- ESG -------

resource "keycloak_openid_client" "esg" {
  realm_id            = keycloak_realm.realm.id
  client_id           = "afc-esg"

  name                = "afc-esg"
  description         = "afc-esg"
  enabled             = true

  access_type         = "PUBLIC"
  valid_redirect_uris = [
    "${var.esg_frontend_url}/*",
    "https://${var.realm_name}.afcdemo.com/*",
    "http://localhost*",
    "http://localhost/*",
    "http://localhost:4200*",
    "http://localhost:4200/*"
  ]
  web_origins = [ "+" ]

  standard_flow_enabled = true
  implicit_flow_enabled = true
  oauth2_device_authorization_grant_enabled = true
  direct_access_grants_enabled = true

  frontchannel_logout_enabled = true
}

resource "keycloak_openid_client_default_scopes" "esg_default_scopes_mapper" {
  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.esg.id

  default_scopes = [
    "acr",
    keycloak_openid_client_scope.client_scopes.name,
    "email",
    "profile",
    "roles",
    "web-origins"
  ]
  depends_on = [ keycloak_realm.realm, keycloak_openid_client.esg, keycloak_openid_client_scope.client_scopes ]
}

resource "keycloak_openid_audience_protocol_mapper" "esg_audience_mapper" {
  realm_id  = keycloak_realm.realm.id
  client_scope_id = keycloak_openid_client_scope.client_scopes.id
  name      = "esg-client-mapper"

  included_client_audience = keycloak_openid_client.esg.client_id
  # included_custom_audience = "afc-esg"
  add_to_access_token = true
  add_to_id_token = false
}

# ------- CARBACC -------

resource "keycloak_openid_client" "carbacc" {
  realm_id            = keycloak_realm.realm.id
  client_id           = "afc-carbacc"

  name                = "afc-carbacc"
  description         = "afc-carbacc"
  enabled             = true

  access_type         = "PUBLIC"
  valid_redirect_uris = [
    "${var.carbacc_frontend_url}/*",
    "https://${var.realm_name}.afcdemo.com/*",
    "http://localhost*",
    "http://localhost/*",
    "http://localhost:4200*",
    "http://localhost:4200/*"
  ]
  web_origins = [ "+" ]

  standard_flow_enabled = true
  implicit_flow_enabled = true
  oauth2_device_authorization_grant_enabled = true
  direct_access_grants_enabled = true

  frontchannel_logout_enabled = true
}

resource "keycloak_openid_client_default_scopes" "carbacc_default_scopes_mapper" {
  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.carbacc.id

  default_scopes = [
    "acr",
    keycloak_openid_client_scope.client_scopes.name,
    "email",
    "profile",
    "roles",
    "web-origins"
  ]
  depends_on = [ keycloak_realm.realm, keycloak_openid_client.carbacc, keycloak_openid_client_scope.client_scopes ]
}

resource "keycloak_openid_audience_protocol_mapper" "carbacc_audience_mapper" {
  realm_id  = keycloak_realm.realm.id
  client_scope_id = keycloak_openid_client_scope.client_scopes.id
  name      = "carbacc-client-mapper"

  included_client_audience = keycloak_openid_client.carbacc.client_id
  # included_custom_audience = "afc-carbacc"
  add_to_access_token = true
  add_to_id_token = false
}

