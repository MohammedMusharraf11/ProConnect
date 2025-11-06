import { Card, CardContent } from '@/components/ui/card';
import { Users, FileText, TrendingUp } from 'lucide-react';

interface UserStatsCardProps {
  connectionCount: number;
  postCount: number;
  profileCompleteness: number;
}

const UserStatsCard = ({ connectionCount, postCount, profileCompleteness }: UserStatsCardProps) => {
  const stats = [
    {
      label: 'Connections',
      value: connectionCount || 0,
      icon: Users,
      color: 'text-blue-600',
      bgColor: 'bg-blue-50',
    },
    {
      label: 'Posts',
      value: postCount || 0,
      icon: FileText,
      color: 'text-green-600',
      bgColor: 'bg-green-50',
    },
    {
      label: 'Profile Strength',
      value: `${profileCompleteness || 0}%`,
      icon: TrendingUp,
      color: 'text-purple-600',
      bgColor: 'bg-purple-50',
    },
  ];

  return (
    <Card>
      <CardContent className="p-0">
        <div className="grid grid-cols-3 divide-x divide-border">
          {stats.map((stat, index) => (
            <div key={index} className="p-4 text-center">
              <div className={`inline-flex items-center justify-center w-10 h-10 rounded-full ${stat.bgColor} mb-2`}>
                <stat.icon className={`h-5 w-5 ${stat.color}`} />
              </div>
              <div className="text-2xl font-bold">{stat.value}</div>
              <div className="text-xs text-muted-foreground">{stat.label}</div>
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  );
};

export default UserStatsCard;
