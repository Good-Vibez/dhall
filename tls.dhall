let v1 =
      λ(TARGET : Text) →
        let x = ./libxs/xs/dsl

        let u/ = ./libxs/util/...

        let cwd = Some [ TARGET ]

        let Req =
              let Subject =
                    { O : Text, OU : Text, EM : Text, ST : Text, L : Text }

              let Data =
                    { names : List Text
                    , name : Text
                    , ips : List Text
                    , subject : Subject
                    }

              let O = "Internet Widgits Pty Ltd"

              let OU = "Ministry of Magic"

              let EM = "emailAddress=webmaster@g.x"

              let ST = "Alabama"

              let L = "Missuri"

              let default =
                    { names = [] : List Text
                    , name = "nowhere.nowhere.com"
                    , ips = [ "127.0.0.1" ]
                    , subject = { O, OU, EM, ST, L }
                    }

              let Object =
                    { data : Data
                    , subj : Text
                    , alt_n : Text
                    , ca-key : Text
                    , ca : Text
                    , key : Text
                    , csr : Text
                    , crt : Text
                    , extfile : Text
                    , p12 : Text
                    }

              let new
                  : Data → Object
                  = λ(data : Data) →
                      let ips = data.ips

                      let name = data.name

                      let names = data.names

                      let subject = data.subject

                      let ST = subject.ST

                      let L = subject.L

                      let O = subject.O

                      let OU = subject.OU

                      let EM = subject.EM

                      let map = u/.list/map Text Text

                      let concat = u/.text/concat_sep ", "

                      let map =
                            λ(f : Text → Text) →
                              u/.fun/compose
                                (List Text)
                                (List Text)
                                Text
                                (map f)
                                concat

                      let names = [ name ] # names

                      let names = map (λ(name : Text) → "DNS:${name}") names

                      let ips = map (λ(ip : Text) → "IP:${ip}") ips

                      let subj =
                            "/C=US/CN=${name}/ST=${ST}/L=${L}/O=${O}/OU=${OU}/${EM}"

                      let alt_n = "subjectAltName = ${names}, ${ips}"

                      let ca-key = "${name}-ca-key.pem"

                      let ca = "${name}-ca.pem"

                      let key = "${name}-key.pem"

                      let csr = "${name}-csr.pem"

                      let crt = "${name}-crt.pem"

                      let extfile = "${name}-req.cnf"

                      let p12 = "${name}.p12"

                      in  { data
                          , subj
                          , alt_n
                          , ca-key
                          , ca
                          , key
                          , csr
                          , crt
                          , extfile
                          , p12
                          }

              let of/name
                  : Text → Object
                  = λ(name : Text) → new (default ⫽ { name })

              in  { Type = Data, default, Object, new, of/name }

        let root/
            : Req.Type → List Text
            = λ(req : Req.Type) →
                let req = Req.new req

                in  [ "req"
                    , "-x509"
                    , "-nodes"
                    , "-days"
                    , "10"
                    , "-subj"
                    , req.subj
                    , "-addext"
                    , req.alt_n
                    , "-new"
                    , "-newkey"
                    , "rsa:2048"
                    , "-keyout"
                    , req.ca-key
                    , "-out"
                    , req.ca
                    ]

        let req/
            : Req.Type → List Text
            = λ(req : Req.Type) →
                let req = Req.new req

                in  [ "req"
                    , "-nodes"
                    , "-batch"
                    , "-new"
                    , "-newkey"
                    , "rsa:2048"
                    , "-keyout"
                    , req.key
                    , "-out"
                    , req.csr
                    , "-subj"
                    , req.subj
                    , "-addext"
                    , req.alt_n
                    ]

        let sign/ =
              λ(auth : Text) →
              λ(req : Req.Type) →
                let req = Req.new req

                let au = Req.of/name auth

                let config =
                      ''
                      ${req.alt_n}
                      ''

                let config-alias = "${req.data.name}-req-config"

                let write_config
                    : x.Script
                    = [ x.alias config-alias (x.std.echo [ x.str config ])
                      , x.exec
                          (   x.std.tee [ req.extfile ]
                            ⫽ x.in/stream config-alias
                            ⫽ { cwd }
                          )
                      ]

                in  { config
                    , write_config
                    , req = req/ req.data
                    , sign =
                      [ "x509"
                      , "-req"
                      , "-in"
                      , req.csr
                      , "-CA"
                      , au.ca
                      , "-CAkey"
                      , au.ca-key
                      , "-CAcreateserial"
                      , "-out"
                      , req.crt
                      , "-extfile"
                      , req.extfile
                      ]
                    }

        let openssl/
            : List Text → x.Exec
            = λ(args : List Text) →
                x.cmd::{ cmd = [ "openssl" ], cwd, args = x.strlist args }

        let sign-seq/
            : Text → Req.Type → x.Script
            = λ(auth : Text) →
              λ(req : Req.Type) →
                let csr = sign/ auth req

                in    [ x.exec (openssl/ csr.req) ]
                    # csr.write_config
                    # [ x.exec (openssl/ csr.sign) ]

        let Domain =
              let Data =
                    { domain : Text
                    , dc : Text
                    , role : Text
                    , n : Natural
                    , m : Natural
                    }

              let to_req
                  : Data → Req.Type
                  = λ(data : Data) →
                      let i = Natural/show data.m

                      in  Req::{
                          , name = "${data.role}-${i}.${data.dc}.${data.domain}"
                          , names = [ "${data.role}.${data.dc}.${data.domain}" ]
                          }

              let default =
                    { dc = "dc-0"
                    , role = "agent"
                    , n = 0
                    , m = 0
                    , domain = "consul"
                    }

              in  { Type = Data, to_req, default }

        let Ip/Subnet/
            : Type → Type
            = λ(a : Type) → Natural → Natural → a

        let Ip/Domain
            : Type
            = Ip/Subnet/ Domain.Type

        let Ip
            : Type
            = Ip/Subnet/ Text

        let ip/
            : Natural → Natural → Ip
            = λ(k : Natural) →
              λ(l : Natural) →
              λ(n : Natural) →
              λ(m : Natural) →
                let i3 = Natural/show k

                let i4 = Natural/show l

                let i0 = Natural/show (8 + n)

                let i1 = Natural/show (4 + m)

                in  "${i3}.${i4}.${i0}.${i1}"

        let with_ips/
            : Ip → Domain.Type → Req.Type
            = λ(ip : Ip) →
              λ(c : Domain.Type) →
                let req = Domain.to_req c

                in  req
                  with ips = req.ips # [ ip c.n c.m ]

        let Predapt2/
            : Type → Type → Type → Type → Type
            = λ(a : Type) →
              λ(b : Type) →
              λ(old : Type) →
              λ(cur : Type) →
                (a → b → old) → a → b → cur

        let with_ips
            : Ip → Predapt2/ Natural Natural Domain.Type Req.Type
            = λ(ip : Ip) →
              λ(c : Natural → Natural → Domain.Type) →
              λ(n : Natural) →
              λ(m : Natural) →
                with_ips/ ip (c n m)

        let target/rm
            : x.Exec
            =   x.cmd::{ cmd = [ "rm" ], args = x.strlist [ "-rvf", TARGET ] }
              ⫽ x.out/display

        let target/mkdir
            : x.Exec
            = x.std.mkdir_p [ TARGET, "" ]

        let lsd
            : x.Exec
            =   x.cmd::{
                , cmd = [ "lsd" ]
                , args = x.strlist [ "--tree", TARGET ]
                }
              ⫽ x.out/display

        let inspect/request
            : Req.Type → x.Exec
            = λ(req : Req.Type) →
                  openssl/
                    [ "req", "-noout", "-text", "-in", (Req.new req).csr ]
                ⫽ x.out/display

        let inspect/crt/alt_n
            : Req.Type → x.Exec
            = λ(req : Req.Type) →
                  openssl/
                    [ "x509"
                    , "-noout"
                    , "-ext"
                    , "subjectAltName,nsCertType"
                    , "-fingerprint"
                    , "-in"
                    , (Req.new req).crt
                    ]
                ⫽ x.out/display

        let make_client_cert
            : Req.Type → List Text
            = λ(req : Req.Type) →
                let req = Req.new req

                in  [ "pkcs12"
                    , "-nodes"
                    , "-export"
                    , "-password"
                    , "pass:k"
                    , "-out"
                    , req.p12
                    , "-inkey"
                    , req.key
                    , "-in"
                    , req.crt
                    ]

        let make_client_cert/exec
            : Req.Type → x.Exec
            = λ(req : Req.Type) → openssl/ (make_client_cert req)

        in  { make_client_cert
            , make_client_cert/exec
            , inspect/crt/alt_n
            , inspect/request
            , lsd
            , target/mkdir
            , target/rm
            , with_ips
            , Predapt2/
            , with_ips/
            , ip/
            , Ip/Subnet/
            , Ip/Domain
            , Ip
            , Domain
            , sign-seq/
            , root/
            , Req
            , openssl/
            }

in  { v1 }
