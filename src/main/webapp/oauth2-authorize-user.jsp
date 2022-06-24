<%@ page import="org.apache.oltu.oauth2.client.request.OAuthClientRequest" %>
<%@ page import="org.wso2.sample.identity.oauth2.OAuth2Constants" %>
<%@ page import="java.util.Properties" %>
<%@ page import="org.wso2.sample.identity.oauth2.SampleContextEventListener" %>
<%@ page import="org.apache.oltu.oauth2.common.exception.OAuthSystemException" %>
<%@ page import="java.net.URL" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page contentType="text/html;charset=UTF-8"%>

<%
    Properties properties = SampleContextEventListener.getProperties();
    
    String consumerKey = properties.getProperty("consumerKey");
    String authzEndpoint = properties.getProperty("authzEndpoint");
    String authzGrantType = properties.getProperty("authzGrantType");
    String scope = properties.getProperty("scope");
    String callBackUrl = properties.getProperty("callBackUrl");
    String OIDC_LOGOUT_ENDPOINT = properties.getProperty("OIDC_LOGOUT_ENDPOINT");
    String sessionIFrameEndpoint = properties.getProperty("sessionIFrameEndpoint");
    boolean enableOIDCSessionManagement = Boolean.parseBoolean(properties.getProperty("enableOIDCSessionManagement"));
    boolean enableOIDCBackchannelLogout = Boolean.parseBoolean(properties.getProperty("enableOIDCBackchannelLogout"));

    session.setAttribute(OAuth2Constants.OAUTH2_GRANT_TYPE, authzGrantType);
    session.setAttribute(OAuth2Constants.CONSUMER_KEY, consumerKey);
    session.setAttribute(OAuth2Constants.SCOPE, scope);
    session.setAttribute(OAuth2Constants.CALL_BACK_URL, callBackUrl);
    session.setAttribute(OAuth2Constants.OAUTH2_AUTHZ_ENDPOINT, authzEndpoint);
    session.setAttribute(OAuth2Constants.OIDC_LOGOUT_ENDPOINT, OIDC_LOGOUT_ENDPOINT);
    session.setAttribute(OAuth2Constants.OIDC_SESSION_IFRAME_ENDPOINT, sessionIFrameEndpoint);
    session.setAttribute(OAuth2Constants.OIDC_SESSION_MANAGEMENT_ENABLED, enableOIDCSessionManagement);
    session.setAttribute(OAuth2Constants.OIDC_BACK_CHANNEL_LOGOUT_ENABLED, enableOIDCBackchannelLogout);

    OAuthClientRequest.AuthenticationRequestBuilder oAuthAuthenticationRequestBuilder =
            new OAuthClientRequest.AuthenticationRequestBuilder(authzEndpoint);
    oAuthAuthenticationRequestBuilder
            .setClientId(consumerKey)
            .setRedirectURI((String) session.getAttribute(OAuth2Constants.CALL_BACK_URL))
            .setResponseType(authzGrantType)
            .setScope(scope);
    
    // Build the new response mode with form post.
    OAuthClientRequest authzRequest;
    try {
        authzRequest = oAuthAuthenticationRequestBuilder.buildQueryMessage();

        URL requestURL = new URL(request.getRequestURL().toString());
        String host = requestURL.getHost();
        String org = host.replace(".medlife.com", "");
        org = org.replace("medlife.com", "");

        if (StringUtils.isBlank(org) || org.contains("localhost")) {
            response.sendRedirect(authzRequest.getLocationUri());
        } else {
            response.sendRedirect(authzRequest.getLocationUri() + "&org=" + org);
        }

        return;
    } catch (OAuthSystemException e) {
%>

<script type="text/javascript">
    window.location = "index.jsp";
</script>

<%
    }
%>
