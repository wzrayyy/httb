# shellcheck disable=SC2034 # for now

[ -n "${HTTP_GUARD__CONSTANTS_SH+x}" ] && return
export HTTP_GUARD__CONSTANTS_SH=''

readonly HTTP_SERVER_VERSION='0.1.0'
readonly HTTP_PROTOCOL_VERSION='HTTP/1.1'
readonly HTTP_SERVER_STRING="httb/${HTTP_SERVER_VERSION}"

readonly HTTP_DEFAULT_HOST='127.0.0.1'
readonly HTTP_DEFAULT_PORT='8081'

declare -Ar HTTP_METHOD_NAMES=(
    [100]='Continue'
    [101]='Switching Protocols'
    [200]='OK'
    [201]='Created'
    [202]='Accepted'
    [203]='Non-Authoritative Information'
    [204]='No Content'
    [205]='Reset Content'
    [206]='Partial Content'
    [239]='Pratusevic'
    [300]='Multiple Choices'
    [301]='Moved Permanently'
    [302]='Found'
    [303]='See Other'
    [304]='Not Modified'
    [305]='Use Proxy'
    [307]='Temporary Redirect'
    [308]='Permanent Redirect'
    [400]='Bad Request'
    [401]='Unauthorized'
    [402]='Payment Required'
    [403]='Forbidden'
    [404]='Not Found'
    [405]='Method Not Allowed'
    [406]='Not Acceptable'
    [407]='Proxy Authentication Required'
    [408]='Request Timeout'
    [409]='Conflict'
    [410]='Gone'
    [411]='Length Required'
    [412]='Precondition Failed'
    [413]='Content Too Large'
    [414]='URI Too Long'
    [415]='Unsupported Media Type'
    [416]='Range Not Satisfiable'
    [417]='Expectation Failed'
    [418]="I'm a teapot"
    [421]='Misdirected Request'
    [422]='Unprocessable Content'
    [426]='Upgrade Required'
    [500]='Internal Server Error'
    [501]='Not Implemented'
    [502]='Bad Gateway'
    [503]='Service Unavailable'
    [504]='Gateway Timeout'
    [505]='HTTP Version Not Supported'
)

declare -Ar HTTP_SUPPORTED_METHODS=(
    [GET]=1
    [HEAD]=1
    [POST]=''
    [PUT]=''
    [DELETE]=''
    [CONNECT]=''
    [OPTIONS]=''
    [TRACE]=''
)

http::_status_code_page() {
    cat <<-EOF
	<!DOCTYPE html>
	<html>
	    <head>
	        <title>${1} ${HTTP_METHOD_NAMES["$1"]}</title>
	    <body>
	        <center><h1>${1} ${HTTP_METHOD_NAMES["$1"]}</h1></center>
	        <hr>
	        <center><address>Server: ${HTTP_SERVER_STRING}</address></center>
	    </body>
	</html>
	EOF
}
