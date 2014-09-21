## io.jl  Some functions for reading/writing GMMs. 
## This code is for exchange with our octave / matlab based system

using MAT

## for compatibility with good-old Netlab's GMM
function savemat(file::String, gmm::GMM) 
    addhist!(gmm,string("GMM written to file ", file))
    matwrite(file, 
             { "gmm" =>         # the default name
              { "ncentres" => gmm.n,
               "nin" => gmm.d,
               "covar_type" => string(gmm.kind),
               "priors" => gmm.w,
               "centres" => gmm.μ,
               "covars" => gmm.Σ,
               "history_s" => string([h.s for h=gmm.hist]),
               "history_t" => [h.t for h=gmm.hist]
               }})
end
                                                                                    
function readmat(file, ::Type{GMM})
    vars = matread(file)
    g = vars["gmm"]        
    n = int(g["ncentres"])
    d = int(g["nin"])
    kind = g["covar_type"]
    gmm = GMM(n, d, :diag)  # I should parse this
    gmm.w = reshape(g["priors"], n)
    gmm.μ = g["centres"]
    gmm.Σ = g["covars"]
    hist_s = split(get(g, "history_s", "No original history"), "\n")
    hist_t = get(g, "history_t", time())
    gmm.hist =  vcat([History(t,s) for (t,s) = zip(hist_t, hist_s)], 
                         History(string("GMM read from file ", file)))
    gmm
end
