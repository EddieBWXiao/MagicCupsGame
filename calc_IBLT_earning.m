function earning = calc_IBLT_earning(actions,wins,losses)

% returns earning of points in a block of IBLT

chose1 = actions == 1;
chose2 = actions == 2;
netwin = sum(wins(chose1,1))+sum(wins(chose2,2));
netloss = sum(losses(chose1,1))+sum(losses(chose2,2));
earning = netwin - netloss;

end