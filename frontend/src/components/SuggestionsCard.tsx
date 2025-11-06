import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Button } from '@/components/ui/button';
import { useNavigate } from 'react-router-dom';
import { useAuthStore } from '@/stores/authStore';
import api from '@/lib/axios';
import toast from 'react-hot-toast';
import { Skeleton } from '@/components/ui/skeleton';

const SuggestionsCard = () => {
  const navigate = useNavigate();
  const { userId } = useAuthStore();
  const queryClient = useQueryClient();

  // Get existing connections
  const { data: connections } = useQuery({
    queryKey: ['connections', userId],
    queryFn: async () => {
      const { data } = await api.get(`/connections/${userId}`);
      return data;
    },
    enabled: !!userId,
  });

  // Get pending sent requests
  const { data: sentRequests } = useQuery({
    queryKey: ['sentRequests'],
    queryFn: async () => {
      const { data } = await api.get('/connections/sent');
      return data;
    },
    enabled: !!userId,
  });

  const { data: suggestions, isLoading } = useQuery({
    queryKey: ['suggestions', userId, connections, sentRequests],
    queryFn: async () => {
      const { data } = await api.get('/users/all');
      
      // Get IDs of connected users
      const connectedIds = new Set(
        connections?.map((conn: any) => conn.USER_ID?.toString()) || []
      );
      
      // Get IDs of users with pending requests
      const pendingIds = new Set(
        sentRequests?.map((req: any) => req.USER_ID?.toString()) || []
      );
      
      // Remove duplicates by USER_ID
      const uniqueUsers = Array.from(
        new Map(data.map((user: any) => [user.USER_ID, user])).values()
      );
      
      // Filter out current user, connected users, and pending requests
      const filtered = uniqueUsers
        .filter((user: any) => {
          const userIdStr = user.USER_ID?.toString();
          return userIdStr !== userId?.toString() && 
                 !connectedIds.has(userIdStr) &&
                 !pendingIds.has(userIdStr);
        })
        .slice(0, 5);
      
      return filtered;
    },
    enabled: !!userId && connections !== undefined && sentRequests !== undefined,
  });

  const connectMutation = useMutation({
    mutationFn: async (receiverId: string) => {
      await api.post('/connections/request', { receiverId });
    },
    onSuccess: () => {
      toast.success('Connection request sent!');
      queryClient.invalidateQueries({ queryKey: ['suggestions'] });
    },
    onError: () => {
      toast.error('Failed to send connection request');
    },
  });

  if (isLoading) {
    return (
      <Card className="overflow-hidden">
        <CardHeader className="pb-3">
          <CardTitle className="text-base font-semibold">People you may know</CardTitle>
        </CardHeader>
        <CardContent className="p-0">
          <div className="divide-y divide-border">
            {[1, 2, 3].map((i) => (
              <div key={i} className="p-4">
                <div className="flex items-center gap-3">
                  <Skeleton className="h-12 w-12 rounded-full" />
                  <div className="flex-1 space-y-2">
                    <Skeleton className="h-4 w-32" />
                    <Skeleton className="h-3 w-full max-w-[200px]" />
                    <Skeleton className="h-3 w-24" />
                  </div>
                  <Skeleton className="h-8 w-20" />
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    );
  }

  if (!suggestions || suggestions.length === 0) {
    return null;
  }

  return (
    <Card className="overflow-hidden">
      <CardHeader className="pb-3">
        <CardTitle className="text-base font-semibold">People you may know</CardTitle>
      </CardHeader>
      <CardContent className="p-0">
        <div className="divide-y divide-border">
          {suggestions.map((user: any) => (
            <div 
              key={user.USER_ID} 
              className="p-4 hover:bg-muted/50 transition-colors"
            >
              <div className="flex items-center gap-3">
                <Avatar 
                  className="h-12 w-12 cursor-pointer ring-2 ring-transparent hover:ring-primary/20 transition-all"
                  onClick={() => navigate(`/profile/${user.USER_ID}`)}
                >
                  <AvatarImage src={user.PROFILE_PIC_URL} />
                  <AvatarFallback className="bg-gradient-to-br from-primary to-primary/80 text-primary-foreground font-semibold">
                    {user.F_NAME?.[0]}{user.L_NAME?.[0]}
                  </AvatarFallback>
                </Avatar>
                
                <div 
                  className="flex-1 min-w-0 cursor-pointer"
                  onClick={() => navigate(`/profile/${user.USER_ID}`)}
                >
                  <p className="font-semibold text-sm hover:text-primary transition-colors truncate">
                    {user.F_NAME} {user.L_NAME}
                  </p>
                  {user.HEADLINE ? (
                    <p className="text-xs text-muted-foreground line-clamp-2 mt-0.5">
                      {user.HEADLINE}
                    </p>
                  ) : (
                    <p className="text-xs text-muted-foreground/60 italic">
                      No headline
                    </p>
                  )}
                  {(user.CITY || user.INDUSTRY) && (
                    <p className="text-xs text-muted-foreground/80 mt-1">
                      {user.CITY && user.INDUSTRY 
                        ? `${user.CITY} • ${user.INDUSTRY}`
                        : user.CITY || user.INDUSTRY
                      }
                    </p>
                  )}
                  {user.connectionCount > 0 && (
                    <p className="text-xs text-muted-foreground/60 mt-0.5">
                      {user.connectionCount} {user.connectionCount === 1 ? 'connection' : 'connections'}
                    </p>
                  )}
                </div>
                
                <Button
                  size="sm"
                  variant="outline"
                  onClick={(e) => {
                    e.stopPropagation();
                    connectMutation.mutate(user.USER_ID.toString());
                  }}
                  disabled={connectMutation.isPending}
                  className="shrink-0 hover:bg-primary hover:text-primary-foreground transition-colors"
                >
                  Connect
                </Button>
              </div>
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  );
};

export default SuggestionsCard;
