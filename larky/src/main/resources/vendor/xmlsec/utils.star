load("@stdlib//larky", larky="larky")
load("@stdlib//types", types="types")
load("@stdlib//codecs", codecs="codecs")
load("@stdlib//xml/etree/ElementTree", etree="ElementTree")
load("@vendor//option/result", Result="Result", Error="Error")
load("@vendor//xmlsec/ns", ns="ns")

NotImplemented = larky.SENTINEL
b64_intro = 64


def b64_print(s):
    """
    Prints a string with spaces at every b64_intro characters
    :param s: String to print
    :return: String
    """
    string = codecs.encode(s, encoding="utf-8")
    r = []
    for pos in range(0, len(string), b64_intro):
        r.append(string[pos : pos + b64_intro])  # noqa: E203

    return "\n".join(r)


def _escape_dn_value(val):
    """Escape special characters in RFC4514 Distinguished Name value."""

    if not val:
        return ""

    # See https://tools.ietf.org/html/rfc4514#section-2.4
    val = val.replace("\\", "\\\\")
    val = val.replace('"', '\\"')
    val = val.replace("+", "\\+")
    val = val.replace(",", "\\,")
    val = val.replace(";", "\\;")
    val = val.replace("<", "\\<")
    val = val.replace(">", "\\>")
    val = val.replace("\0", "\\00")

    if val[0] in ("#", " "):
        val = "\\" + val
    if val[-1] == " ":
        val = val[:-1] + "\\ "

    return val


def os2ip(arr):
    x_len = len(arr)
    x = 0
    for i in range(x_len):
        val = arr[i]
        x = x + (val * pow(256, x_len - i - 1))
    return x


def create_node(name, parent=None, ns="", tail=False, text=False):
    """
    Creates a new node
    :param name: Node name
    :param parent: Node parent
    :param ns: Namespace to use
    :param tail: Tail to add
    :param text: Text of the node
    :return: New node
    """
    node = etree.Element(etree.QName(ns, name))
    if parent != None:
        parent.append(node)
    if tail:
        node.tail = tail
    if text:
        node.text = text
    return node


_OID_NAMES = {}


def ObjectIdentifier(dotted_string):
    self = larky.mutablestruct(__name__='ObjectIdentifier', __class__=ObjectIdentifier)
    def __init__(dotted_string):
        self._dotted_string = dotted_string

        nodes = self._dotted_string.split(".")
        intnodes = []

        # There must be at least 2 nodes, the first node must be 0..2, and
        # if less than 2, the second node cannot have a value outside the
        # range 0..39.  All nodes must be integers.
        for node in nodes:
            node_value = (Result.Ok(node)
                          .map(lambda x: int(x, 10))
                          .unwrap_or("ValueError: " + "Malformed OID: %s (non-integer nodes)" % (self._dotted_string)))
            if node_value < 0:
                return Error("ValueError: " + "Malformed OID: %s (negative-integer nodes)" % (self._dotted_string)
                ).unwrap()
            intnodes.append(node_value)

        if len(nodes) < 2:
            return Error("ValueError: " + "Malformed OID: %s (insufficient number of nodes)"
                % (self._dotted_string)
            ).unwrap()

        if intnodes[0] > 2:
            return Error("ValueError: " + "Malformed OID: %s (first node outside valid range)"
                % (self._dotted_string)
            ).unwrap()

        if intnodes[0] < 2 and intnodes[1] >= 40:
            return Error("ValueError: " + "Malformed OID: %s (second node outside valid range)"
                % (self._dotted_string)
            ).unwrap()
        return self
    self = __init__(dotted_string)

    def __eq__(other):
        if not types.is_instance(other, ObjectIdentifier):
            return NotImplemented

        return self.dotted_string == other.dotted_string
    self.__eq__ = __eq__

    def __ne__(other):
        return not self.__eq__(other)
    self.__ne__ = __ne__

    def __repr__():
        return "<ObjectIdentifier(oid={}, name={})>".format(
            self.dotted_string, self._name
        )
    self.__repr__ = __repr__

    def __hash__():
        return hash(self.dotted_string)
    self.__hash__ = __hash__

    self._hashable = None

    def _name():
        return _OID_NAMES.get(self._hashable, "Unknown OID")

    def dotted_string():
        return self._dotted_string

    # hashable
    self._hashable = larky.struct(
        _name=larky.property(_name),
        dotted_string=larky.property(dotted_string),
        **self.__dict__
    )
    return self._hashable
    # self._name = larky.property(_name)
    # self.dotted_string = larky.property(dotted_string)


ExtensionOID = larky.struct(
    __name__='ExtensionOID',
    SUBJECT_DIRECTORY_ATTRIBUTES = ObjectIdentifier("2.5.29.9"),
    SUBJECT_KEY_IDENTIFIER = ObjectIdentifier("2.5.29.14"),
    KEY_USAGE = ObjectIdentifier("2.5.29.15"),
    SUBJECT_ALTERNATIVE_NAME = ObjectIdentifier("2.5.29.17"),
    ISSUER_ALTERNATIVE_NAME = ObjectIdentifier("2.5.29.18"),
    BASIC_CONSTRAINTS = ObjectIdentifier("2.5.29.19"),
    NAME_CONSTRAINTS = ObjectIdentifier("2.5.29.30"),
    CRL_DISTRIBUTION_POINTS = ObjectIdentifier("2.5.29.31"),
    CERTIFICATE_POLICIES = ObjectIdentifier("2.5.29.32"),
    POLICY_MAPPINGS = ObjectIdentifier("2.5.29.33"),
    AUTHORITY_KEY_IDENTIFIER = ObjectIdentifier("2.5.29.35"),
    POLICY_CONSTRAINTS = ObjectIdentifier("2.5.29.36"),
    EXTENDED_KEY_USAGE = ObjectIdentifier("2.5.29.37"),
    FRESHEST_CRL = ObjectIdentifier("2.5.29.46"),
    INHIBIT_ANY_POLICY = ObjectIdentifier("2.5.29.54"),
    ISSUING_DISTRIBUTION_POINT = ObjectIdentifier("2.5.29.28"),
    AUTHORITY_INFORMATION_ACCESS = ObjectIdentifier("1.3.6.1.5.5.7.1.1"),
    SUBJECT_INFORMATION_ACCESS = ObjectIdentifier("1.3.6.1.5.5.7.1.11"),
    OCSP_NO_CHECK = ObjectIdentifier("1.3.6.1.5.5.7.48.1.5"),
    TLS_FEATURE = ObjectIdentifier("1.3.6.1.5.5.7.1.24"),
    CRL_NUMBER = ObjectIdentifier("2.5.29.20"),
    DELTA_CRL_INDICATOR = ObjectIdentifier("2.5.29.27"),
    PRECERT_SIGNED_CERTIFICATE_TIMESTAMPS = ObjectIdentifier(
        "1.3.6.1.4.1.11129.2.4.2"
    ),
    PRECERT_POISON = ObjectIdentifier("1.3.6.1.4.1.11129.2.4.3"),
    SIGNED_CERTIFICATE_TIMESTAMPS = ObjectIdentifier("1.3.6.1.4.1.11129.2.4.5"),
)

OCSPExtensionOID = larky.struct(
    __name__='OCSPExtensionOID',
    NONCE = ObjectIdentifier("1.3.6.1.5.5.7.48.1.2")
)


CRLEntryExtensionOID = larky.struct(
    __name__='CRLEntryExtensionOID',
    CERTIFICATE_ISSUER = ObjectIdentifier("2.5.29.29"),
    CRL_REASON = ObjectIdentifier("2.5.29.21"),
    INVALIDITY_DATE = ObjectIdentifier("2.5.29.24"),
)

SignatureAlgorithmOID = larky.struct(
    __name__='SignatureAlgorithmOID',
    RSA_WITH_MD5 = ObjectIdentifier("1.2.840.113549.1.1.4"),
    RSA_WITH_SHA1 = ObjectIdentifier("1.2.840.113549.1.1.5"),
    # This is an alternate OID for RSA with SHA1 that is occasionally seen
    _RSA_WITH_SHA1 = ObjectIdentifier("1.3.14.3.2.29"),
    RSA_WITH_SHA224 = ObjectIdentifier("1.2.840.113549.1.1.14"),
    RSA_WITH_SHA256 = ObjectIdentifier("1.2.840.113549.1.1.11"),
    RSA_WITH_SHA384 = ObjectIdentifier("1.2.840.113549.1.1.12"),
    RSA_WITH_SHA512 = ObjectIdentifier("1.2.840.113549.1.1.13"),
    RSASSA_PSS = ObjectIdentifier("1.2.840.113549.1.1.10"),
    ECDSA_WITH_SHA1 = ObjectIdentifier("1.2.840.10045.4.1"),
    ECDSA_WITH_SHA224 = ObjectIdentifier("1.2.840.10045.4.3.1"),
    ECDSA_WITH_SHA256 = ObjectIdentifier("1.2.840.10045.4.3.2"),
    ECDSA_WITH_SHA384 = ObjectIdentifier("1.2.840.10045.4.3.3"),
    ECDSA_WITH_SHA512 = ObjectIdentifier("1.2.840.10045.4.3.4"),
    DSA_WITH_SHA1 = ObjectIdentifier("1.2.840.10040.4.3"),
    DSA_WITH_SHA224 = ObjectIdentifier("2.16.840.1.101.3.4.3.1"),
    DSA_WITH_SHA256 = ObjectIdentifier("2.16.840.1.101.3.4.3.2"),
    ED25519 = ObjectIdentifier("1.3.101.112"),
    ED448 = ObjectIdentifier("1.3.101.113"),
    GOSTR3411_94_WITH_3410_2001 = ObjectIdentifier("1.2.643.2.2.3"),
    GOSTR3410_2012_WITH_3411_2012_256 = ObjectIdentifier("1.2.643.7.1.1.3.2"),
    GOSTR3410_2012_WITH_3411_2012_512 = ObjectIdentifier("1.2.643.7.1.1.3.3"),
)

_SIG_OIDS_TO_HASH = {
    # SignatureAlgorithmOID.RSA_WITH_MD5: hashes.MD5(),
    # SignatureAlgorithmOID.RSA_WITH_SHA1: hashes.SHA1(),
    # SignatureAlgorithmOID._RSA_WITH_SHA1: hashes.SHA1(),
    # SignatureAlgorithmOID.RSA_WITH_SHA224: hashes.SHA224(),
    # SignatureAlgorithmOID.RSA_WITH_SHA256: hashes.SHA256(),
    # SignatureAlgorithmOID.RSA_WITH_SHA384: hashes.SHA384(),
    # SignatureAlgorithmOID.RSA_WITH_SHA512: hashes.SHA512(),
    # SignatureAlgorithmOID.ECDSA_WITH_SHA1: hashes.SHA1(),
    # SignatureAlgorithmOID.ECDSA_WITH_SHA224: hashes.SHA224(),
    # SignatureAlgorithmOID.ECDSA_WITH_SHA256: hashes.SHA256(),
    # SignatureAlgorithmOID.ECDSA_WITH_SHA384: hashes.SHA384(),
    # SignatureAlgorithmOID.ECDSA_WITH_SHA512: hashes.SHA512(),
    # SignatureAlgorithmOID.DSA_WITH_SHA1: hashes.SHA1(),
    # SignatureAlgorithmOID.DSA_WITH_SHA224: hashes.SHA224(),
    # SignatureAlgorithmOID.DSA_WITH_SHA256: hashes.SHA256(),
    # SignatureAlgorithmOID.ED25519: None,
    # SignatureAlgorithmOID.ED448: None,
    # SignatureAlgorithmOID.GOSTR3411_94_WITH_3410_2001: None,
    # SignatureAlgorithmOID.GOSTR3410_2012_WITH_3411_2012_256: None,
    # SignatureAlgorithmOID.GOSTR3410_2012_WITH_3411_2012_512: None,
}


ExtendedKeyUsageOID = larky.struct(
    __name__='ExtendedKeyUsageOID',
    SERVER_AUTH = ObjectIdentifier("1.3.6.1.5.5.7.3.1"),
    CLIENT_AUTH = ObjectIdentifier("1.3.6.1.5.5.7.3.2"),
    CODE_SIGNING = ObjectIdentifier("1.3.6.1.5.5.7.3.3"),
    EMAIL_PROTECTION = ObjectIdentifier("1.3.6.1.5.5.7.3.4"),
    TIME_STAMPING = ObjectIdentifier("1.3.6.1.5.5.7.3.8"),
    OCSP_SIGNING = ObjectIdentifier("1.3.6.1.5.5.7.3.9"),
    ANY_EXTENDED_KEY_USAGE = ObjectIdentifier("2.5.29.37.0"),
    SMARTCARD_LOGON = ObjectIdentifier("1.3.6.1.4.1.311.20.2.2"),
    KERBEROS_PKINIT_KDC = ObjectIdentifier("1.3.6.1.5.2.3.5"),
)

AuthorityInformationAccessOID = larky.struct(
    __name__='AuthorityInformationAccessOID',
    CA_ISSUERS = ObjectIdentifier("1.3.6.1.5.5.7.48.2"),
    OCSP = ObjectIdentifier("1.3.6.1.5.5.7.48.1"),
)

SubjectInformationAccessOID = larky.struct(
    __name__='SubjectInformationAccessOID',
    CA_REPOSITORY = ObjectIdentifier("1.3.6.1.5.5.7.48.5")
)


CertificatePoliciesOID = larky.struct(
    __name__='CertificatePoliciesOID',
    CPS_QUALIFIER = ObjectIdentifier("1.3.6.1.5.5.7.2.1"),
    CPS_USER_NOTICE = ObjectIdentifier("1.3.6.1.5.5.7.2.2"),
    ANY_POLICY = ObjectIdentifier("2.5.29.32.0"),
)


AttributeOID = larky.struct(
    __name__='AttributeOID',
    CHALLENGE_PASSWORD = ObjectIdentifier("1.2.840.113549.1.9.7"),
    UNSTRUCTURED_NAME = ObjectIdentifier("1.2.840.113549.1.9.2"),
)

NameOID = larky.struct(
    __name__='NameOID',
    COMMON_NAME = ObjectIdentifier("2.5.4.3"),
    COUNTRY_NAME = ObjectIdentifier("2.5.4.6"),
    LOCALITY_NAME = ObjectIdentifier("2.5.4.7"),
    STATE_OR_PROVINCE_NAME = ObjectIdentifier("2.5.4.8"),
    STREET_ADDRESS = ObjectIdentifier("2.5.4.9"),
    ORGANIZATION_NAME = ObjectIdentifier("2.5.4.10"),
    ORGANIZATIONAL_UNIT_NAME = ObjectIdentifier("2.5.4.11"),
    SERIAL_NUMBER = ObjectIdentifier("2.5.4.5"),
    SURNAME = ObjectIdentifier("2.5.4.4"),
    GIVEN_NAME = ObjectIdentifier("2.5.4.42"),
    TITLE = ObjectIdentifier("2.5.4.12"),
    GENERATION_QUALIFIER = ObjectIdentifier("2.5.4.44"),
    X500_UNIQUE_IDENTIFIER = ObjectIdentifier("2.5.4.45"),
    DN_QUALIFIER = ObjectIdentifier("2.5.4.46"),
    PSEUDONYM = ObjectIdentifier("2.5.4.65"),
    USER_ID = ObjectIdentifier("0.9.2342.19200300.100.1.1"),
    DOMAIN_COMPONENT = ObjectIdentifier("0.9.2342.19200300.100.1.25"),
    EMAIL_ADDRESS = ObjectIdentifier("1.2.840.113549.1.9.1"),
    JURISDICTION_COUNTRY_NAME = ObjectIdentifier("1.3.6.1.4.1.311.60.2.1.3"),
    JURISDICTION_LOCALITY_NAME = ObjectIdentifier("1.3.6.1.4.1.311.60.2.1.1"),
    JURISDICTION_STATE_OR_PROVINCE_NAME = ObjectIdentifier("1.3.6.1.4.1.311.60.2.1.2"),
    BUSINESS_CATEGORY = ObjectIdentifier("2.5.4.15"),
    POSTAL_ADDRESS = ObjectIdentifier("2.5.4.16"),
    POSTAL_CODE = ObjectIdentifier("2.5.4.17"),
    INN = ObjectIdentifier("1.2.643.3.131.1.1"),
    OGRN = ObjectIdentifier("1.2.643.100.1"),
    SNILS = ObjectIdentifier("1.2.643.100.3"),
    UNSTRUCTURED_NAME = ObjectIdentifier("1.2.840.113549.1.9.2"),
)

#: Short attribute names from RFC 4514:
#: https://tools.ietf.org/html/rfc4514#page-7
_NAMEOID_TO_NAME = {
    NameOID.COMMON_NAME: "CN",
    NameOID.LOCALITY_NAME: "L",
    NameOID.STATE_OR_PROVINCE_NAME: "ST",
    NameOID.ORGANIZATION_NAME: "O",
    NameOID.ORGANIZATIONAL_UNIT_NAME: "OU",
    NameOID.COUNTRY_NAME: "C",
    NameOID.STREET_ADDRESS: "STREET",
    NameOID.DOMAIN_COMPONENT: "DC",
    NameOID.USER_ID: "UID",
    NameOID.EMAIL_ADDRESS: "E",
}

_OID_NAMES.update({
    NameOID.COMMON_NAME: "commonName",
    NameOID.COUNTRY_NAME: "countryName",
    NameOID.LOCALITY_NAME: "localityName",
    NameOID.STATE_OR_PROVINCE_NAME: "stateOrProvinceName",
    NameOID.STREET_ADDRESS: "streetAddress",
    NameOID.ORGANIZATION_NAME: "organizationName",
    NameOID.ORGANIZATIONAL_UNIT_NAME: "organizationalUnitName",
    NameOID.SERIAL_NUMBER: "serialNumber",
    NameOID.SURNAME: "surname",
    NameOID.GIVEN_NAME: "givenName",
    NameOID.TITLE: "title",
    NameOID.GENERATION_QUALIFIER: "generationQualifier",
    NameOID.X500_UNIQUE_IDENTIFIER: "x500UniqueIdentifier",
    NameOID.DN_QUALIFIER: "dnQualifier",
    NameOID.PSEUDONYM: "pseudonym",
    NameOID.USER_ID: "userID",
    NameOID.DOMAIN_COMPONENT: "domainComponent",
    NameOID.EMAIL_ADDRESS: "emailAddress",
    NameOID.JURISDICTION_COUNTRY_NAME: "jurisdictionCountryName",
    NameOID.JURISDICTION_LOCALITY_NAME: "jurisdictionLocalityName",
    NameOID.JURISDICTION_STATE_OR_PROVINCE_NAME: (
        "jurisdictionStateOrProvinceName"
    ),
    NameOID.BUSINESS_CATEGORY: "businessCategory",
    NameOID.POSTAL_ADDRESS: "postalAddress",
    NameOID.POSTAL_CODE: "postalCode",
    NameOID.INN: "INN",
    NameOID.OGRN: "OGRN",
    NameOID.SNILS: "SNILS",
    NameOID.UNSTRUCTURED_NAME: "unstructuredName",
    SignatureAlgorithmOID.RSA_WITH_MD5: "md5WithRSAEncryption",
    SignatureAlgorithmOID.RSA_WITH_SHA1: "sha1WithRSAEncryption",
    SignatureAlgorithmOID.RSA_WITH_SHA224: "sha224WithRSAEncryption",
    SignatureAlgorithmOID.RSA_WITH_SHA256: "sha256WithRSAEncryption",
    SignatureAlgorithmOID.RSA_WITH_SHA384: "sha384WithRSAEncryption",
    SignatureAlgorithmOID.RSA_WITH_SHA512: "sha512WithRSAEncryption",
    SignatureAlgorithmOID.RSASSA_PSS: "RSASSA-PSS",
    SignatureAlgorithmOID.ECDSA_WITH_SHA1: "ecdsa-with-SHA1",
    SignatureAlgorithmOID.ECDSA_WITH_SHA224: "ecdsa-with-SHA224",
    SignatureAlgorithmOID.ECDSA_WITH_SHA256: "ecdsa-with-SHA256",
    SignatureAlgorithmOID.ECDSA_WITH_SHA384: "ecdsa-with-SHA384",
    SignatureAlgorithmOID.ECDSA_WITH_SHA512: "ecdsa-with-SHA512",
    SignatureAlgorithmOID.DSA_WITH_SHA1: "dsa-with-sha1",
    SignatureAlgorithmOID.DSA_WITH_SHA224: "dsa-with-sha224",
    SignatureAlgorithmOID.DSA_WITH_SHA256: "dsa-with-sha256",
    SignatureAlgorithmOID.ED25519: "ed25519",
    SignatureAlgorithmOID.ED448: "ed448",
    SignatureAlgorithmOID.GOSTR3411_94_WITH_3410_2001: (
        "GOST R 34.11-94 with GOST R 34.10-2001"
    ),
    SignatureAlgorithmOID.GOSTR3410_2012_WITH_3411_2012_256: (
        "GOST R 34.10-2012 with GOST R 34.11-2012 (256 bit)"
    ),
    SignatureAlgorithmOID.GOSTR3410_2012_WITH_3411_2012_512: (
        "GOST R 34.10-2012 with GOST R 34.11-2012 (512 bit)"
    ),
    ExtendedKeyUsageOID.SERVER_AUTH: "serverAuth",
    ExtendedKeyUsageOID.CLIENT_AUTH: "clientAuth",
    ExtendedKeyUsageOID.CODE_SIGNING: "codeSigning",
    ExtendedKeyUsageOID.EMAIL_PROTECTION: "emailProtection",
    ExtendedKeyUsageOID.TIME_STAMPING: "timeStamping",
    ExtendedKeyUsageOID.OCSP_SIGNING: "OCSPSigning",
    ExtendedKeyUsageOID.SMARTCARD_LOGON: "msSmartcardLogin",
    ExtendedKeyUsageOID.KERBEROS_PKINIT_KDC: "pkInitKDC",
    ExtensionOID.SUBJECT_DIRECTORY_ATTRIBUTES: "subjectDirectoryAttributes",
    ExtensionOID.SUBJECT_KEY_IDENTIFIER: "subjectKeyIdentifier",
    ExtensionOID.KEY_USAGE: "keyUsage",
    ExtensionOID.SUBJECT_ALTERNATIVE_NAME: "subjectAltName",
    ExtensionOID.ISSUER_ALTERNATIVE_NAME: "issuerAltName",
    ExtensionOID.BASIC_CONSTRAINTS: "basicConstraints",
    ExtensionOID.PRECERT_SIGNED_CERTIFICATE_TIMESTAMPS: (
        "signedCertificateTimestampList"
    ),
    ExtensionOID.SIGNED_CERTIFICATE_TIMESTAMPS: (
        "signedCertificateTimestampList"
    ),
    ExtensionOID.PRECERT_POISON: "ctPoison",
    CRLEntryExtensionOID.CRL_REASON: "cRLReason",
    CRLEntryExtensionOID.INVALIDITY_DATE: "invalidityDate",
    CRLEntryExtensionOID.CERTIFICATE_ISSUER: "certificateIssuer",
    ExtensionOID.NAME_CONSTRAINTS: "nameConstraints",
    ExtensionOID.CRL_DISTRIBUTION_POINTS: "cRLDistributionPoints",
    ExtensionOID.CERTIFICATE_POLICIES: "certificatePolicies",
    ExtensionOID.POLICY_MAPPINGS: "policyMappings",
    ExtensionOID.AUTHORITY_KEY_IDENTIFIER: "authorityKeyIdentifier",
    ExtensionOID.POLICY_CONSTRAINTS: "policyConstraints",
    ExtensionOID.EXTENDED_KEY_USAGE: "extendedKeyUsage",
    ExtensionOID.FRESHEST_CRL: "freshestCRL",
    ExtensionOID.INHIBIT_ANY_POLICY: "inhibitAnyPolicy",
    ExtensionOID.ISSUING_DISTRIBUTION_POINT: ("issuingDistributionPoint"),
    ExtensionOID.AUTHORITY_INFORMATION_ACCESS: "authorityInfoAccess",
    ExtensionOID.SUBJECT_INFORMATION_ACCESS: "subjectInfoAccess",
    ExtensionOID.OCSP_NO_CHECK: "OCSPNoCheck",
    ExtensionOID.CRL_NUMBER: "cRLNumber",
    ExtensionOID.DELTA_CRL_INDICATOR: "deltaCRLIndicator",
    ExtensionOID.TLS_FEATURE: "TLSFeature",
    AuthorityInformationAccessOID.OCSP: "OCSP",
    AuthorityInformationAccessOID.CA_ISSUERS: "caIssuers",
    SubjectInformationAccessOID.CA_REPOSITORY: "caRepository",
    CertificatePoliciesOID.CPS_QUALIFIER: "id-qt-cps",
    CertificatePoliciesOID.CPS_USER_NOTICE: "id-qt-unotice",
    OCSPExtensionOID.NONCE: "OCSPNonce",
    AttributeOID.CHALLENGE_PASSWORD: "challengePassword",
})

def get_rdns_name(rdns):
    """
    Gets the rdns String name
    :param rdns: RDNS object
    :type rdns: cryptography.x509.RelativeDistinguishedName
    :return: RDNS name
    """
    data = []
    XMLSIG_NAMEOID_TO_NAME = dict(**_NAMEOID_TO_NAME)
    XMLSIG_NAMEOID_TO_NAME[NameOID.SERIAL_NUMBER] = "SERIALNUMBER"
    for dn in rdns:
        dn_data = []
        for attribute in dn._attributes:
            key = XMLSIG_NAMEOID_TO_NAME.get(
                attribute.oid, "OID.%s" % attribute.oid.dotted_string
            )
            dn_data.insert(0, "{}={}".format(key, _escape_dn_value(attribute.value)))
        data.insert(0, "+".join(dn_data))
    return ", ".join(data)


def detect_soap_env(envelope):
    root_tag = etree.QName(envelope)
    return root_tag.namespace


def get_or_create_header(envelope):
    soap_env = detect_soap_env(envelope)

    # look for the Header element and create it if not found
    header_qname = "{%s}Header" % soap_env
    header = envelope.find(header_qname)
    if header == None:
        header = etree.Element(header_qname)
        envelope.insert(0, header)
    return header