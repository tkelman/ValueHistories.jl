using ValueHistories

_is_plotable_history(::UnivalueHistory) = false
_is_plotable_history{I,V<:Real}(::QueueUnivalueHistory{I,V}) = true
_is_plotable_history{I,V<:Real}(::VectorUnivalueHistory{I,V}) = true

_filter_plotable_histories(h::DynMultivalueHistory) =
    filter((k,v) -> _is_plotable_history(v), h.storage)

@recipe function plot(h::Union{VectorUnivalueHistory,QueueUnivalueHistory})
    :markershape --> :ellipse
    :markersize  --> 1.5
    :legend      --> false
    get(h)
end

@recipe function plot(h::DynMultivalueHistory)
    filtered = _filter_plotable_histories(h)
    k_vec = [k for (k, v) in filtered]
    v_vec = [v for (k, v) in filtered]
    if length(v_vec) > 0
        :markershape --> :ellipse
        :markersize  --> 1.5
        :label       --> map(string, k_vec)'
        if issubplot && get!(d, :n, length(v_vec)) == length(v_vec)
            :title   --> d[:label]
            :legend  --> false
        else
            :title   --> "Multivalue History"
            :legend  --> true
        end
        get_vec = map(get, v_vec)
        [x for (x, y) in get_vec], [y for (x, y) in get_vec]
    else
        throw(ArgumentError("Can't plot an empty history, nor a history with strange types"))
    end
end
